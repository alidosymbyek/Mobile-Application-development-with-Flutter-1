import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/format.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final ValueChanged<Item> onFavouriteToggled;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onFavouriteToggled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final places = item.places;

    // Determine badge text (R19)
    String? badgeText;
    if (item.isFull) {
      badgeText = 'FULL';
    } else if (places.free <= 5) {
      badgeText = '${places.free} left';
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar Stack with Positioned badge (R18, R19)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: item.category.colorRole(colorScheme),
                    child: Icon(
                      item.category.icon,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  if (badgeText != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isFull
                              ? colorScheme.error
                              : colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Expanded column with title (2 lines ellipsis), date, and place
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${FormatUtils.formatDate(item.when)} • ${item.place}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Favourite button on the right (R18)
              IconButton(
                icon: Icon(
                  item.favourite ? Icons.favorite : Icons.favorite_border,
                  color: item.favourite ? Colors.red : null,
                ),
                onPressed: () => onFavouriteToggled(
                  item.copyWith(favourite: !item.favourite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
