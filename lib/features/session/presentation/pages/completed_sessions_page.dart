import 'package:flutter/material.dart';

class CompletedSessionsPage extends StatelessWidget {
	const CompletedSessionsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: EdgeInsets.zero,
			children: const [
				_CompletedSessionCard(
					lockerCode: 'B11',
					dateTime: 'Jan 21, 03:45 PM',
					duration: '01:20:13',
				),
				SizedBox(height: 12),
				_CompletedSessionCard(
					lockerCode: 'C02',
					dateTime: 'Jan 20, 09:10 AM',
					duration: '00:52:40',
				),
			],
		);
	}
}

class _CompletedSessionCard extends StatelessWidget {
	const _CompletedSessionCard({
		required this.lockerCode,
		required this.dateTime,
		required this.duration,
	});

	final String lockerCode;
	final String dateTime;
	final String duration;

	@override
	Widget build(BuildContext context) {
		return Container(
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
								padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
								decoration: BoxDecoration(
									color: const Color(0xFFECFDF3),
									borderRadius: BorderRadius.circular(12),
								),
								child: const Text(
									'Completed',
									style: TextStyle(
										fontSize: 12,
										fontWeight: FontWeight.w600,
										color: Color(0xFF166534),
									),
								),
							),
						],
					),
					const SizedBox(height: 8),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(
								dateTime,
								style: const TextStyle(
									fontSize: 12,
									color: Color(0xFF6B7280),
								),
							),
							Text(
								'Duration: $duration',
								style: const TextStyle(
									fontSize: 12,
									color: Color(0xFF6B7280),
									fontWeight: FontWeight.w500,
								),
							),
						],
					),
				],
			),
		);
	}
}
