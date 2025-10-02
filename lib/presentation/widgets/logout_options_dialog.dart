import 'package:flutter/material.dart';
import 'package:spotify_app/data/services/auth_service.dart';
import 'package:spotify_app/injection_container.dart';

class LogoutOptionsDialog extends StatefulWidget {
  const LogoutOptionsDialog({super.key});

  @override
  State<LogoutOptionsDialog> createState() => _LogoutOptionsDialogState();
}

class _LogoutOptionsDialogState extends State<LogoutOptionsDialog> {
  final _authService = sl<AuthService>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF282828),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout, color: Color(0xFF1DB954)),
          SizedBox(width: 8),
          Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo te gustaría cerrar sesión?',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Opción 1: Logout completo
          _buildLogoutOption(
            icon: Icons.logout,
            title: 'Cerrar Sesión Completa',
            subtitle: 'Cierra la sesión de esta app',
            onTap: () => _performLogout(false),
            color: const Color(0xFF1DB954),
          ),

          const SizedBox(height: 12),

          // Opción 2: Logout con cambio de usuario
          _buildLogoutOption(
            icon: Icons.switch_account,
            title: 'Cambiar Usuario de Spotify',
            subtitle: 'Permite cambiar la cuenta de Spotify',
            onTap: () => _performLogout(true),
            color: Colors.orange,
          ),

          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildLogoutOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performLogout(bool useSpotifyDialog) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      if (useSpotifyDialog) {
        // Logout con diálogo de Spotify
        success = await _authService.logoutWithSpotifyDialog();

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sesión de Spotify actualizada. Puedes elegir una cuenta diferente.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // Logout completo
        await _authService.logout();
        success = true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión cerrada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (success && mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout cancelado'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Widget helper para mostrar el diálogo
class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;
  final bool isIconOnly;

  const LogoutButton({super.key, this.onLogout, this.isIconOnly = false});

  @override
  Widget build(BuildContext context) {
    return isIconOnly
        ? IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
          )
        : TextButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
          );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutOptionsDialog(),
    );
  }
}
