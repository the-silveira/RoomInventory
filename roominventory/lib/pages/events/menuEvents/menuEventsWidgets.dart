import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/events/menuEvents/menuEventsController.dart';

class EventSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const EventSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        controller: controller,
        onChanged: onChanged,
        placeholder: 'Search events...',
      ),
    );
  }
}

class EventListTile extends StatelessWidget {
  final dynamic event;
  final menuEventosController controller;
  final BuildContext context;

  const EventListTile({
    Key? key,
    required this.event,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile.notched(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  event['EventName'].toString().isEmpty
                      ? 'Empty Name'
                      : event['EventName'].toString().length > 35
                          ? event['EventName'].toString().substring(0, 35) +
                              "..."
                          : event['EventName'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                controller.getCardIcon(event['Date']),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📍 ${event['EventPlace']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "👤 ${event['NameRep']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "📧 ${event['EmailRep']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "🛠 ${event['TecExt']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "📅 Date: ${event['Date']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "ID: ${event['IdEvent']}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => controller.navigateToDetails(context, event['IdEvent']),
        ),
      ],
    );
  }
}

class EventsListView extends StatelessWidget {
  final menuEventosController controller;
  final TextEditingController searchController;

  const EventsListView({
    Key? key,
    required this.controller,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return Center(child: Text(controller.errorMessage));
    }

    if (controller.filteredEvents.isEmpty) {
      return Center(
        child: Text(
          "Não tem Eventos Registados",
          style: TextStyle(
            fontSize: 16,
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
        ),
      );
    }

    return Expanded(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: controller.refreshData,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var event = controller.filteredEvents[index];
                return EventListTile(
                  event: event,
                  controller: controller,
                  context: context,
                );
              },
              childCount: controller.filteredEvents.length,
            ),
          ),
        ],
      ),
    );
  }
}
