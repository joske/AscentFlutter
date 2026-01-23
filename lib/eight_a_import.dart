import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'database.dart';
import 'model/ascent.dart';

class EightAImportScreen extends StatefulWidget {
  const EightAImportScreen({super.key});

  @override
  State<EightAImportScreen> createState() => _EightAImportScreenState();
}

class _EightAImportScreenState extends State<EightAImportScreen> {
  String? _userSlug;
  bool _isLoading = false;
  bool _showWebView = true;
  List<Ascent>? _ascents;
  String? _error;
  int _importedCount = 0;
  int _skippedCount = 0;
  int _updatedCount = 0;

  late final WebViewController _controller;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _onPageFinished,
          onUrlChange: (change) {
            if (change.url != null) {
              _extractUserSlug(change.url!);
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: _onJavaScriptMessage,
      )
      ..loadRequest(Uri.parse('https://www.8a.nu/'));
  }

  List<Ascent> _fetchedAscents = [];
  bool _stopFetching = false;

  void _onJavaScriptMessage(JavaScriptMessage message) async {
    try {
      final data = jsonDecode(message.message);
      if (data['type'] == 'page') {
        final ascentsJson = data['data']['ascents'] as List;
        final pageAscents = ascentsJson.map((item) => Ascent.fromJson(item)).toList();

        // Check if we should stop (all ascents on this page already exist)
        int existingCount = 0;
        for (final ascent in pageAscents) {
          bool exists = false;
          if (ascent.eightAId != null) {
            exists = await DatabaseHelper.ascentExistsByEightAId(ascent.eightAId!);
          }
          if (!exists && ascent.route?.name != null && ascent.date != null && ascent.route?.grade != null) {
            final dateStr = ascent.date!.toIso8601String().substring(0, 10);
            exists = await DatabaseHelper.ascentExists(ascent.route!.name!, dateStr, ascent.route!.grade!);
          }
          if (exists) existingCount++;
        }

        _fetchedAscents.addAll(pageAscents);

        // Stop if all ascents on this page exist (we've caught up)
        if (pageAscents.isNotEmpty && existingCount == pageAscents.length) {
          _stopFetching = true;
        }

        // Tell JS whether to continue
        await _controller.runJavaScript('window.continueSync = ${!_stopFetching};');

      } else if (data['type'] == 'done') {
        setState(() {
          _ascents = _fetchedAscents;
          _isLoading = false;
          _showWebView = false;
        });
      } else if (data['type'] == 'error') {
        setState(() {
          _error = data['message'] ?? 'Failed to fetch ascents';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to parse response: $e';
        _isLoading = false;
      });
    }
  }

  void _extractUserSlug(String url) {
    final slugMatch = RegExp(r'/user/([^/]+)').firstMatch(url);
    if (slugMatch != null) {
      final slug = slugMatch.group(1);
      if (slug != null && slug != 'login' && slug != _userSlug) {
        setState(() {
          _userSlug = slug;
        });
      }
    }
  }

  Future<void> _onPageFinished(String url) async {
    // Check if logged in by looking for logout or account elements
    final result = await _controller.runJavaScriptReturningResult(
      'document.querySelector("a[href*=\\"logout\\"]") !== null || document.querySelector("button[aria-label*=\\"account\\"]") !== null || document.querySelector("[data-testid=\\"user-avatar\\"]") !== null || document.body.innerHTML.includes("Sign out")'
    );

    final loggedIn = result.toString() == 'true';
    final wasLoggedIn = _isLoggedIn;
    if (loggedIn != _isLoggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }

    _extractUserSlug(url);

    // Auto-navigate to profile after login
    if (loggedIn && !wasLoggedIn && _userSlug == null) {
      // Find the user's profile link and navigate there
      final profileUrl = await _controller.runJavaScriptReturningResult(
        '(function() { var link = document.querySelector("a[href*=\\"/user/\\"][href*=\\"sportclimbing\\"]") || document.querySelector("a[href*=\\"/user/\\"]"); return link ? link.href : ""; })()'
      );
      final urlStr = profileUrl.toString().replaceAll('"', '');
      if (urlStr.isNotEmpty && urlStr.contains('/user/')) {
        _controller.loadRequest(Uri.parse(urlStr));
      }
    }
  }

  Future<void> _onFetchPressed() async {
    // Try to get user slug from current URL
    final currentUrl = await _controller.currentUrl();
    if (currentUrl != null) {
      final slugMatch = RegExp(r'/user/([^/]+)').firstMatch(currentUrl);
      if (slugMatch != null) {
        final slug = slugMatch.group(1);
        if (slug != null && slug != 'login') {
          _userSlug = slug;
        }
      }
    }
    await _fetchAscents();
  }

  Future<void> _fetchAscents() async {
    if (_userSlug == null) {
      setState(() {
        _error = 'Please navigate to your profile page first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    _fetchedAscents = [];
    _stopFetching = false;

    // Use JavaScript to fetch from within the WebView (cookies are automatically included)
    final js = '''
      (async function() {
        try {
          window.continueSync = true;
          let pageIndex = 0;

          while (window.continueSync) {
            const url = 'https://www.8a.nu/api/unification/ascent/v1/web/users/$_userSlug/ascents?category=sportclimbing&pageIndex=' + pageIndex + '&pageSize=50&sortField=date_desc&timeFilter=0&gradeFilter=0&includeProjects=true&showRepeats=true&showDuplicates=false';
            const response = await fetch(url);
            if (!response.ok) {
              FlutterChannel.postMessage(JSON.stringify({type: 'error', message: 'HTTP ' + response.status}));
              return;
            }
            const data = await response.json();

            if (data.ascents.length === 0) {
              break;
            }

            // Send page to Flutter and wait for decision
            FlutterChannel.postMessage(JSON.stringify({type: 'page', data: {ascents: data.ascents, pageIndex: pageIndex}}));

            // Wait a bit for Flutter to process and set continueSync
            await new Promise(r => setTimeout(r, 100));
            pageIndex++;
          }

          FlutterChannel.postMessage(JSON.stringify({type: 'done'}));
        } catch (e) {
          FlutterChannel.postMessage(JSON.stringify({type: 'error', message: e.toString()}));
        }
      })();
    ''';

    await _controller.runJavaScript(js);
  }

  Future<void> _importAscents() async {
    if (_ascents == null || _ascents!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _importedCount = 0;
      _skippedCount = 0;
      _updatedCount = 0;
    });

    for (final ascent in _ascents!) {
      // Check by eightAId first, then by route name + date + grade
      bool exists = false;
      if (ascent.eightAId != null) {
        exists = await DatabaseHelper.ascentExistsByEightAId(ascent.eightAId!);
      }
      if (!exists && ascent.route?.name != null && ascent.date != null && ascent.route?.grade != null) {
        final dateStr = ascent.date!.toIso8601String().substring(0, 10);
        exists = await DatabaseHelper.ascentExists(ascent.route!.name!, dateStr, ascent.route!.grade!);
        // Update eightAId if entry exists but doesn't have one
        if (exists && ascent.eightAId != null) {
          final updated = await DatabaseHelper.updateEightAIdIfMissing(
            ascent.route!.name!, dateStr, ascent.route!.grade!, ascent.eightAId!
          );
          if (updated) _updatedCount++;
        }
      }

      if (exists) {
        _skippedCount++;
      } else {
        await DatabaseHelper.createAscent(ascent);
        _importedCount++;
      }
      setState(() {});
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Synced $_importedCount new, skipped $_skippedCount, linked $_updatedCount'),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Material(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 50),
            child: _buildBody(context),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync with 8a.nu'),
        actions: [
          if (_showWebView && _userSlug != null)
            TextButton(
              onPressed: _onFetchPressed,
              child: const Text('Fetch', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            if (_ascents != null)
              Text('Importing... $_importedCount / ${_ascents!.length}')
            else
              const Text('Fetching ascents...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _showWebView = true;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ascents != null && !_showWebView) {
      return _buildAscentsPreview();
    }

    return Column(
      children: [
        _buildStatusBar(),
        Expanded(
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final hasProfile = _userSlug != null;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Icon(
            _isLoggedIn ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _isLoggedIn ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(_isLoggedIn ? 'Logged in' : 'Please log in'),
          const SizedBox(width: 24),
          Icon(
            hasProfile ? Icons.check_circle : Icons.radio_button_unchecked,
            color: hasProfile ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasProfile ? 'Profile: $_userSlug' : 'Navigate to your profile',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAscentsPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found ${_ascents!.length} ascents. Review and import.',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _ascents!.length,
            itemBuilder: (context, index) {
              final ascent = _ascents![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    ascent.route?.grade ?? '?',
                    style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                  ),
                ),
                title: Text(ascent.route?.name ?? 'Unknown'),
                subtitle: Text(
                  '${ascent.route?.crag?.name ?? ''} - ${ascent.style?.shortName ?? ''}',
                ),
                trailing: Text(
                  ascent.date?.toString().substring(0, 10) ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showWebView = true;
                        _ascents = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _importAscents,
                    child: const Text('Sync'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
