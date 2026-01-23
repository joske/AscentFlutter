import 'package:ascent/model/ascent.dart';
import 'package:ascent/database.dart';
import 'package:ascent/widgets/adaptive/adaptive.dart';
import 'package:ascent/widgets/grade_badge.dart';
import 'package:ascent/widgets/style_chip.dart';
import 'package:flutter/material.dart';

class Top10Screen extends StatefulWidget {
  @override
  _Top10ScreenState createState() => _Top10ScreenState();
}

class _Top10ScreenState extends State<Top10Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSegment = 0;
  static const _segments = ['All Time', 'Last 12 Months'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Top 10',
      previousPageTitle: 'More',
      bottom: AdaptiveSegmentedControl.buildTabBar(
        segments: _segments,
        controller: _tabController,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildScoreHeader(),
        // iOS: show segmented control in body
        AdaptiveSegmentedControl(
          selectedIndex: _selectedSegment,
          segments: _segments,
          onValueChanged: (value) => setState(() => _selectedSegment = value),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (PlatformUtils.isIOS) {
      // iOS: use state-based switching
      return _selectedSegment == 0
          ? _buildTop10List(DatabaseHelper.getTop10AllTime())
          : _buildTop10List(DatabaseHelper.getTop10Last12Months());
    }
    // Android: use TabBarView
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTop10List(DatabaseHelper.getTop10AllTime()),
        _buildTop10List(DatabaseHelper.getTop10Last12Months()),
      ],
    );
  }

  Widget _buildScoreHeader() {
    return FutureBuilder<List<int>>(
      future: Future.wait([
        DatabaseHelper.getTop10ScoreAllTime(),
        DatabaseHelper.getTop10ScoreLast12Months(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 60);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: AdaptiveStatCard(label: 'All Time', value: snapshot.data![0].toString(), color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: AdaptiveStatCard(label: 'Last 12 Months', value: snapshot.data![1].toString(), color: Colors.green)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTop10List(Future<List<Ascent>> future) {
    return FutureBuilder<List<Ascent>>(
      future: future,
      initialData: List.empty(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ascents yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => _buildRankCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildRankCard(Ascent ascent) {
    final isDark = PlatformUtils.isDarkMode(context);

    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GradeBadge(grade: ascent.route?.grade ?? '?'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ascent.route?.name ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PlatformUtils.textColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ascent.route?.crag?.name ?? '',
                  style: TextStyle(fontSize: 12, color: PlatformUtils.secondaryTextColor(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (ascent.style != null) StyleChip(style: ascent.style!),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue[900] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ascent.score?.toString() ?? '0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[200] : Colors.blue[700],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
