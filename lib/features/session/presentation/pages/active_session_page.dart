import 'package:face_locker/features/session/presentation/pages/detail_active_session_page.dart';
import 'package:flutter/material.dart';

class ActiveSessionsPage extends StatelessWidget {
	const ActiveSessionsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: EdgeInsets.zero,
			children: const [
				_ActiveSessionCard(
					lockerCode: 'A05',
					dateTime: 'Jan 23, 10:00 AM',
					location: 'Floor 1 - Zone B',
				),
				SizedBox(height: 12),
				_ActiveSessionCard(
					lockerCode: 'D14',
					dateTime: 'Jan 23, 11:20 AM',
					location: 'Floor 2 - Zone A',
				),
			],
		);
	}
}

class _ActiveSessionCard extends StatelessWidget {
	const _ActiveSessionCard({
		required this.lockerCode,
		required this.dateTime,
		required this.location,
	});

	final String lockerCode;
	final String dateTime;
	final String location;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			borderRadius: BorderRadius.circular(12),
			onTap: () {
				Navigator.of(context).push(
					MaterialPageRoute(
						builder: (context) => const DetailActiveSessionPage(),
					),
				);
			},
			child: Container(
				padding: const EdgeInsets.all(16),
				decoration: BoxDecoration(
					color: Colors.white,
					border: Border.all(color: const Color(0xFFE5E7EB)),
					borderRadius: BorderRadius.circular(12),
				),
				child: Column(
					children: [
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text(
									lockerCode,
									style: const TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.w700,
										color: Color(0xFF1F2937),
									),
								),
								Container(
									padding: const EdgeInsets.symmetric(
										horizontal: 12,
										vertical: 6,
									),
									decoration: BoxDecoration(
										color: const Color(0xFFDBEAFE),
										borderRadius: BorderRadius.circular(12),
									),
									child: const Text(
										'Active',
										style: TextStyle(
											fontSize: 12,
											fontWeight: FontWeight.w600,
											color: Color(0xFF1E40AF),
										),
									),
								),
							],
						),
						const SizedBox(height: 8),
						Row(
							children: [
								const Icon(
									Icons.schedule_rounded,
									size: 16,
									color: Color(0xFF6B7280),
								),
								const SizedBox(width: 6),
								Text(
									dateTime,
									style: const TextStyle(
										fontSize: 12,
										color: Color(0xFF6B7280),
									),
								),
							],
						),
						const SizedBox(height: 6),
						Row(
							children: [
								const Icon(
									Icons.place_outlined,
									size: 16,
									color: Color(0xFF6B7280),
								),
								const SizedBox(width: 6),
								Text(
									location,
									style: const TextStyle(
										fontSize: 12,
										color: Color(0xFF6B7280),
									),
								),
							],
						),
					],
				),
			),
		);
	}
}
