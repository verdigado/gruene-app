import 'package:flutter/material.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/features/mfa/dtos/login_attempt_dto.dart';
import 'package:gruene_app/i18n/translations.g.dart';
import 'package:intl/intl.dart';

class LoginAttemptCard extends StatelessWidget {
  final LoginAttemptDto loginAttempt;
  final String? title;

  const LoginAttemptCard({super.key, required this.loginAttempt, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(2, 4), blurRadius: 16, spreadRadius: 7),
        ],
      ),

      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...(title != null ? [Text(title!, style: theme.textTheme.titleSmall), const SizedBox(height: 8)] : []),
              Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    children: [
                      Text(t.mfa.verify.application),
                      Text(
                        loginAttempt.clientName,
                        style: title == null ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700) : null,
                      ),
                    ],
                  ),
                  TableRow(children: [Text(t.mfa.verify.device), Text('${loginAttempt.browser} ${loginAttempt.os}')]),
                  TableRow(children: [Text(t.mfa.verify.date), Text(loginAttempt.loggedInAt.formattedDate)]),
                  TableRow(
                    children: [
                      Text(t.mfa.verify.time),
                      Text(
                        t.mfa.verify.pointInTime(
                          time: DateFormat(DateFormat.HOUR_MINUTE_SECOND).format(loginAttempt.loggedInAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
