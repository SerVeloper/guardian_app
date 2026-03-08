import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/slide_action_button.dart';
import '../../../map/presentation/pages/map_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const _GuardianBottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HomeHeader(),
              SizedBox(height: 18),
              _SecurityStatusCard(),
              SizedBox(height: 18),
              _ActionButtonsSection(),
              SizedBox(height: 18),
              _SectionHeader(
                title: 'Contactos de emergencia',
                actionText: 'Ver todo',
              ),
              SizedBox(height: 8),
              _EmergencyContactsCard(),
              SizedBox(height: 18),
              _SectionHeader(
                title: 'Viajes recientes',
                actionText: 'Ver historial',
              ),
              SizedBox(height: 8),
              _RecentTripsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.shield_outlined,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 6),
        const Text(
          'Guardian',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil presionado')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.account_circle_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  const _SecurityStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF69C35A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de seguridad',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Zona segura',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideActionButton(
          label: 'Iniciar recorrido',
          backgroundColor: AppColors.primary,
          knobColor: Colors.white,
          iconColor: AppColors.primary,
          onSubmit: () {
            Navigator.pushNamed(context, '/map');
          },
        ),
        const SizedBox(height: 16),

SlideActionButton(
  label: 'Activar SOS',
  backgroundColor: const Color(0xFFE80F2F),
  knobColor: Colors.white,
  iconColor: const Color(0xFFE80F2F),
  onSubmit: () async {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS activado')),
    );

    // Ir a pantalla de emergencia
    Navigator.pushNamed(context, '/emergencia');

    // Esperar 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    // Ir a pantalla que empieza a grabar
    Navigator.pushNamed(context, '/emergencia-record');
  },
),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionHeader({
    required this.title,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$actionText presionado')),
            );
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyContactsCard extends StatelessWidget {
  const _EmergencyContactsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _ContactItem(name: 'Ros', phone: '+591 74747567'),
          _ContactItem(name: 'Carlos', phone: '+591 74747567'),
          _ContactItem(name: 'Dori', phone: '+591 74747567'),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String name;
  final String phone;

  const _ContactItem({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFD1E7E7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.groups_2_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        phone,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Llamar a $name')),
          );
        },
        child: const Icon(
          Icons.call_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }
}

class _RecentTripsCard extends StatelessWidget {
  const _RecentTripsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _TripItem(
            address: 'Av. Juana Azurduy',
            date: 'Hoy, 14:30',
            status: 'Completado',
          ),
          _TripItem(
            address: 'Av. Juana Azurduy',
            date: 'Ayer, 14:30',
            status: 'Completado',
          ),
        ],
      ),
    );
  }
}

class _TripItem extends StatelessWidget {
  final String address;
  final String date;
  final String status;

  const _TripItem({
    required this.address,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFE4F5DD),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Color(0xFF7BCB68),
          size: 20,
        ),
      ),
      title: Text(
        address,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        status,
        style: const TextStyle(
          color: Color(0xFF67B85A),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GuardianBottomNavigation extends StatelessWidget {
  const _GuardianBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.shield_outlined,
            label: 'Inicio',
            isActive: true,
          ),
          _NavItem(
            icon: Icons.access_time_outlined,
            label: 'Historial',
          ),
          _NavItem(
            icon: Icons.people_outline,
            label: 'Contactos',
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        isActive ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}