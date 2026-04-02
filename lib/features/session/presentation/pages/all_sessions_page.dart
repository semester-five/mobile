import 'package:flutter/material.dart';

class AllSessionsPage extends StatelessWidget {
	const AllSessionsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: EdgeInsets.zero,
			children: const [
				_SessionCard(
					lockerCode: 'A05',
					dateTime: 'Jan 23, 10:00 AM',
					status: 'Active',
				),
				SizedBox(height: 12),
				_SessionCard(
					lockerCode: 'B11',
					dateTime: 'Jan 21, 03:45 PM',
					status: 'Completed',
				),
				SizedBox(height: 12),
				_SessionCard(
					lockerCode: 'C02',
					dateTime: 'Jan 20, 09:10 AM',
					status: 'Completed',
				),
			],
		);
	}
}

class _SessionCard extends StatelessWidget {
	const _SessionCard({
		required this.lockerCode,
		required this.dateTime,
		required this.status,
	});

	final String lockerCode;
	final String dateTime;
	final String status;

	bool get _isActive => status == 'Active';

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				border: Border.all(color: const Color(0xFFE5E7EB)),
				borderRadius: BorderRadius.circular(12),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								lockerCode,
								style: const TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.w700,
									color: Color(0xFF1F2937),
								),
							),
							const SizedBox(height: 8),
							Text(
								dateTime,
								style: const TextStyle(
									fontSize: 12,
									color: Color(0xFF6B7280),
								),
							),
						],
					),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
						decoration: BoxDecoration(
							color: _isActive
									? const Color(0xFFDBEAFE)
									: const Color(0xFFECFDF3),
							borderRadius: BorderRadius.circular(12),
						),
						child: Text(
							status,
							style: TextStyle(
								fontSize: 12,
								fontWeight: FontWeight.w600,
								color: _isActive
										? const Color(0xFF1E40AF)
										: const Color(0xFF166534),
							),
						),
					),
				],
			),
		);
	}
}
