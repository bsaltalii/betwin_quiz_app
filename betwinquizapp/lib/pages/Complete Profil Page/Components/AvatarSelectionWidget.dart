import 'package:flutter/material.dart';

class AvatarSelectionWidget extends StatefulWidget {
  final List<String> avatarImages;
  final Function(String) onAvatarSelected;

  const AvatarSelectionWidget({
    super.key,
    required this.avatarImages,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelectionWidget> createState() => _AvatarSelectionWidgetState();
}

class _AvatarSelectionWidgetState extends State<AvatarSelectionWidget> {
  String selectedAvatar = '';

  void _handleAvatarTap(String avatar) {
    setState(() => selectedAvatar = avatar);
    widget.onAvatarSelected(avatar);
  }

  Widget _buildAvatarItem(String avatar, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleAvatarTap(avatar),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.asset(
                avatar,
                fit: BoxFit.cover,
              ),
              if (isSelected)
                const Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: widget.avatarImages.length,
        itemBuilder: (context, index) {
          final avatar = widget.avatarImages[index];
          final isSelected = avatar == selectedAvatar;
          return _buildAvatarItem(avatar, isSelected);
        },
      ),
    );
  }
}
