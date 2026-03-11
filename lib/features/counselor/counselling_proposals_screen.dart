import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/counselor_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../models/counselling_proposal_model.dart';
import 'chat_screen.dart';

class CounsellingProposalsScreen extends StatefulWidget {
  const CounsellingProposalsScreen({super.key});

  @override
  State<CounsellingProposalsScreen> createState() =>
      _CounsellingProposalsScreenState();
}

class _CounsellingProposalsScreenState
    extends State<CounsellingProposalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselorController>().loadProposals(
        counselorId: context.read<AuthController>().user?.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.watch<CounselorController>();

    return GlassScaffold(
      appBar: const GlassAppBar(title: AppStrings.counsellingProposals),
      body: counselor.proposals.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 56,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.noProposals,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: counselor.proposals.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
              itemBuilder: (context, index) {
                final proposal = counselor.proposals[index];
                return AnimatedListItem(
                  index: index,
                  child: _ProposalCard(proposal: proposal),
                );
              },
            ),
    );
  }
}

class _ProposalCard extends StatefulWidget {
  final CounsellingProposal proposal;

  const _ProposalCard({required this.proposal});

  @override
  State<_ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<_ProposalCard> {
  bool _isExpanded = false;

  void _showActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.read<CounselorController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Respond to Proposal',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'From ${widget.proposal.parentName} for ${widget.proposal.studentName}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Accept button
            GestureDetector(
              onTap: () {
                final proposal = widget.proposal;
                final authCtrl = context.read<AuthController>();
                counselor.respondToProposal(
                    proposal.id, ProposalStatus.accepted,
                    counselorId: authCtrl.user?.id);

                // Cross-fire: update parent's linked student counselor info
                final counselorPhone = authCtrl.user?.phone ?? '';
                final parentCtrl = context.read<ParentController>();
                parentCtrl.onProposalAccepted(
                  counselorName: proposal.counselorName,
                  counselorPhone: counselorPhone,
                  studentId: proposal.studentId,
                );

                Navigator.pop(ctx);
                Helpers.showSnackBar(context, AppStrings.proposalAccepted);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.buttonGradientDark
                      : AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppStrings.acceptProposal,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Contact parent options row
            Row(
              children: [
                // Chat with parent
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      counselor.respondToProposal(
                          widget.proposal.id, ProposalStatus.discussion,
                          counselorId: context.read<AuthController>().user?.id);
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CounselorChatScreen(
                            studentName: widget.proposal.parentName,
                            studentId: widget.proposal.parentId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Chat',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Call parent
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      counselor.respondToProposal(
                          widget.proposal.id, ProposalStatus.discussion,
                          counselorId: context.read<AuthController>().user?.id);
                      Navigator.pop(ctx);
                      Helpers.showSnackBar(
                          context,
                          'Calling ${widget.proposal.parentName}...');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.successBright
                              : AppColors.success,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.successBright
                                  : AppColors.success),
                          const SizedBox(width: 8),
                          Text(
                            'Call',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.successBright
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proposal = widget.proposal;
    final isPending = proposal.status == ProposalStatus.pending;

    return SurfaceCard(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    (isDark ? AppColors.primaryBright : AppColors.primary)
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                child: Text(
                  proposal.parentName[0],
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryBright
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.parentName,
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Student: ${proposal.studentName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: proposal.status),
            ],
          ),
          const SizedBox(height: 12),

          // Summary row
          Row(
            children: [
              Icon(Icons.event_note_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${proposal.numberOfSessions} sessions',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                Helpers.timeAgo(proposal.createdAt),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Reason (truncated unless expanded)
          if (!_isExpanded) ...[
            const SizedBox(height: 8),
            Text(
              proposal.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],

          // Expanded details
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _DetailSection(
              label: AppStrings.proposalReasonLabel,
              content: proposal.reason,
            ),
            const SizedBox(height: 12),
            _DetailSection(
              label: AppStrings.expectedOutcomes,
              content: proposal.expectedOutcomes,
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showActions(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? AppColors.buttonGradientDark
                              : AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Respond',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],

          // Expand/collapse indicator
          Center(
            child: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProposalStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color) = switch (status) {
      ProposalStatus.pending => ('Pending', AppColors.warning),
      ProposalStatus.accepted => ('Accepted', AppColors.success),
      ProposalStatus.declined => ('Declined', AppColors.error),
      ProposalStatus.discussion => ('Discussion', isDark ? AppColors.primaryBright : AppColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final String content;

  const _DetailSection({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.5,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
