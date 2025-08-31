import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectedAccountsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> connectedAccounts;
  final Function(String) onAccountTap;

  const ConnectedAccountsWidget({
    Key? key,
    required this.connectedAccounts,
    required this.onAccountTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "บัญชีที่เชื่อมต่อ",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => onAccountTap("add_account"),
                  child: Text(
                    "เพิ่มบัญชี",
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: connectedAccounts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.getBorderColor(context),
            ),
            itemBuilder: (context, index) {
              final account = connectedAccounts[index];
              return _buildAccountItem(context, account);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, Map<String, dynamic> account) {
    final bool isConnected = account["isConnected"] as bool;

    return InkWell(
      onTap: () => onAccountTap(account["platform"] as String),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: (account["color"] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomImageWidget(
                imageUrl: account["logo"] as String,
                width: 6.w,
                height: 6.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account["platform"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    isConnected
                        ? account["username"] as String
                        : "ไม่ได้เชื่อมต่อ",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isConnected
                          ? AppTheme.getTextColor(context, secondary: true)
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : AppTheme.lightTheme.colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.getTextColor(context, secondary: true),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
