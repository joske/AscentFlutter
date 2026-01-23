import 'dart:io';

import 'package:ascent/model/ascent.dart';
import 'package:ascent/database.dart';
import 'package:ascent/widgets/grade_badge.dart';
import 'package:ascent/widgets/style_chip.dart';
import 'package:flutter/material.dart';

class Top10Screen extends StatefulWidget {
  @override
  _Top10ScreenState createState() => _Top10ScreenState();
}

class _Top10ScreenState extends State<Top10Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    if (Platform.isIOS) {
      return Material(
        child: Container(
          padding: EdgeInsets.only(top: 100.0, bottom: 100),
          child: _buildBody(context),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Top 10'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Time'),
            Tab(text: 'Last 12 Months'),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildScoreHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTop10List(DatabaseHelper.getTop10AllTime()),
              _buildTop10List(DatabaseHelper.getTop10Last12Months()),
            ],
          ),
        ),
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
        int scoreAllTime = snapshot.data![0];
        int scoreLast12 = snapshot.data![1];
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildScoreCard('All Time', scoreAllTime, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildScoreCard('Last 12 Months', scoreLast12, Colors.green)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
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
          itemBuilder: (context, index) {
            return _buildRankCard(index + 1, snapshot.data![index]);
          },
        );
      },
    );
  }

  Widget _buildRankCard(int rank, Ascent ascent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Grade badge
            GradeBadge(grade: ascent.route?.grade ?? '?'),
            const SizedBox(width: 12),
            // Route info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ascent.route?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ascent.route?.crag?.name ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Style chip
            if (ascent.style != null) StyleChip(style: ascent.style!),
            const SizedBox(width: 8),
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ascent.score?.toString() ?? '0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
