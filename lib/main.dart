import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  title: 'Choose Your Adventure Game',
  home: AdventureGame(),
));

class Room {
  final String name;
  final String description;
  final Map<String, int> exits;

  Room({required this.name, required this.description, required this.exits});
}

class AdventureGame extends StatefulWidget {
  const AdventureGame({Key? key}) : super(key: key);

  @override
  State<AdventureGame> createState() => _AdventureGameState();
}

class _AdventureGameState extends State<AdventureGame> {
  final Map<int, Room> _rooms = {
    0: Room(
      name: 'Foyer',
      description:
      'You stand in the castle foyer. Dusty banners hang from the walls. There are doors to the north and east.',
      exits: {'north': 1, 'east': 2},
    ),
    1: Room(
      name: 'Library',
      description:
      'Rows of old books and a warm lamp. A ladder leads up; a door to the south returns you to the foyer.',
      exits: {'south': 0, 'up': 4},
    ),
    2: Room(
      name: 'Kitchen',
      description:
      'The smell of stew — though long cold. There\'s a door west back to the foyer and one south to the garden.',
      exits: {'west': 0, 'south': 5},
    ),
    3: Room(
      name: 'Dungeon',
      description:
      'Dark and damp, with chains on the wall. A stair climbs up to the tower (north).',
      exits: {'north': 4},
    ),
    4: Room(
      name: 'Tower',
      description:
      'Wind rushes by as you look across the kingdom. A stair leads down to the library, and another path goes down to the dungeon.',
      exits: {'south': 1, 'down': 3},
    ),
    5: Room(
      name: 'Garden',
      description:
      'Wildflowers and a bubbling fountain. A path leads north back to the kitchen.',
      exits: {'north': 2},
    ),
  };

  int _currentRoomId = 0;


  final List<String> _directions = ['north', 'south', 'east', 'west'];

  void _move(String direction) {
    final currentRoom = _rooms[_currentRoomId]!;
    final targetId = currentRoom.exits[direction];

    if (targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot go $direction from here.')),
      );
      return;
    }

    setState(() {
      _currentRoomId = targetId;
    });
  }

  Future<void> _exitGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Exit Game'),
            content: const Text('Are you sure you want to exit the game?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
    );
  }

  Widget _directionButton(String dir) {
    final label = '${dir[0].toUpperCase()}${dir.substring(1)}';
    return ElevatedButton(
      onPressed: () => _move(dir),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = _rooms[_currentRoomId]!;

    // Build direction buttons only for valid exits
    final availableDirectionButtons = <Widget>[];
    for (final d in _directions) {
      if (room.exits.containsKey(d)) {
        availableDirectionButtons.add(_directionButton(d));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Adventure Game'),
        actions: [
          IconButton(
            tooltip: 'Exit',
            icon: const Icon(Icons.exit_to_app),
            onPressed: _exitGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Room title (with animation)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                room.name,
                key: ValueKey<int>(_currentRoomId),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            const SizedBox(height: 12),

            // Room description (with slide animation)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: Text(
                room.description,
                key: ValueKey<int>(_currentRoomId + 1000),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

            const Spacer(),

            // Direction buttons
            if (availableDirectionButtons.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: availableDirectionButtons,
              ),
              const SizedBox(height: 16),
            ] else
              const Text('No exits from here.'),

            // Show exit names as chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: room.exits.keys
                  .map((k) => Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 4.0),
                child: Chip(label: Text(k.toUpperCase())),
              ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Exit button
            ElevatedButton.icon(
              onPressed: _exitGame,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit Game'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
