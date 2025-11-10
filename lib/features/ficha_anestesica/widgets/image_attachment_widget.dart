import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget para gerenciar upload e exibição de imagens na ficha anestésica
class ImageAttachmentWidget extends StatelessWidget {
  final List<String> imagePaths;
  final Function(String) onImageAdded;
  final Function(String) onImageRemoved;

  const ImageAttachmentWidget({
    Key? key,
    required this.imagePaths,
    required this.onImageAdded,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botão para adicionar imagem
        Row(
          children: [
            Text(
              'Imagens Anexadas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            IconButton.outlined(
              icon: const Icon(Icons.add_photo_alternate),
              tooltip: 'Adicionar imagem',
              onPressed: () => _showImageSourceDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Grid de imagens
        if (imagePaths.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nenhuma imagem anexada',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = imagePaths[index];
              return _ImageThumbnail(
                imagePath: imagePath,
                onRemove: () => onImageRemoved(imagePath),
                onTap: () => _showImagePreview(context, imagePath),
              );
            },
          ),
      ],
    );
  }

  /// Mostra diálogo para selecionar fonte da imagem (câmera ou galeria)
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                subtitle: const Text('Tirar uma foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                subtitle: const Text('Selecionar da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Solicita permissões e seleciona imagem
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Solicitar permissões
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;

      final status = await permission.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDeniedDialog(context, source);
        }
        return;
      }

      // Selecionar imagem
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        onImageAdded(image.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagem adicionada com sucesso'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar imagem: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Mostra diálogo quando permissão é negada
  void _showPermissionDeniedDialog(BuildContext context, ImageSource source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Necessária'),
        content: Text(
          source == ImageSource.camera
              ? 'É necessário conceder permissão de acesso à câmera para tirar fotos.'
              : 'É necessário conceder permissão de acesso à galeria para selecionar imagens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  /// Mostra preview da imagem em tela cheia
  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail de imagem com botão de remoção
class _ImageThumbnail extends StatelessWidget {
  final String imagePath;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _ImageThumbnail({
    required this.imagePath,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          // Botão de remover
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filled(
              icon: const Icon(Icons.close, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              onPressed: () {
                // Confirmar remoção
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Remover Imagem'),
                    content: const Text('Deseja realmente remover esta imagem?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRemove();
                        },
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
