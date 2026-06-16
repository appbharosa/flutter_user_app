import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as sl;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../domain/entities/subscription_plan.dart';
import '../../../../domain/entities/user_subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../create_order_bloc/subscription_payment_bloc.dart';
import '../create_order_bloc/subscription_payment_event.dart';
import '../create_order_bloc/subscription_payment_state.dart';
import '../../../../core/services/cashfree_service.dart';
import '../../../../domain/entities/subscription_order.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../subscription_status_bloc/subscription_status_bloc.dart';
import '../subscription_status_bloc/subscription_status_event.dart';
import '../subscription_status_bloc/subscription_status_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late SubscriptionStatusBloc _statusBloc;
  late SubscriptionBloc _subscriptionBloc;
  late SubscriptionPaymentBloc _paymentBloc;

  // Track selected plan index (for UI highlight)
  int _selectedPlanIndex = 0;

  @override
  void initState() {
    super.initState();
    _statusBloc = sl.sl<SubscriptionStatusBloc>();
    _subscriptionBloc = sl.sl<SubscriptionBloc>();
    _paymentBloc = sl.sl<SubscriptionPaymentBloc>();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final language = await LanguageService.getCurrentLanguage();
    _statusBloc.add(LoadUserSubscription(language));

    final hasActive = await UserManager.hasActiveSubscription();
    if (!hasActive) {
      // Optionally, we could clear local flag here, but the API will tell us.
      // We'
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _statusBloc),
        BlocProvider.value(value: _subscriptionBloc),
        BlocProvider.value(value: _paymentBloc),
      ],
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Care Plan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.whiteColor,
              ),
            ),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<SubscriptionPaymentBloc, SubscriptionPaymentState>(
                listener: (context, state) async {
                  if (state is SubscriptionPaymentSuccess) {
                    await UserManager.setSubscriptionActive(true);
                    showSuccessSnackBar('Subscription successful!');
                    _loadSubscriptionStatus();
                  } else if (state is SubscriptionPaymentError) {
                    showErrorSnackBar(state.message);
                  }
                },
              ),
              BlocListener<SubscriptionStatusBloc, SubscriptionStatusState>(
                listener: (context, state) async {
                  if (state is SubscriptionStatusError) {
                    showErrorSnackBar(state.message);
                    // If error indicates no active subscription, clear flag
                    if (state.message.contains('no active subscription') ||
                        state.message.contains('No subscription found')) {
                      await UserManager.setSubscriptionActive(false);
                    }
                  } else if (state is SubscriptionStatusLoaded) {
                    // Sync local flag with actual API result
                    final hasActive = (state.subscription != null && !state.subscription!.isExpired);
                    await UserManager.setSubscriptionActive(hasActive);
                  }
                },
              ),
            ],
            child: RefreshIndicator(
              onRefresh: _loadSubscriptionStatus,
              child: BlocBuilder<SubscriptionStatusBloc, SubscriptionStatusState>(
                builder: (context, state) {
                  if (state is SubscriptionStatusLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SubscriptionStatusError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSubscriptionStatus,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is SubscriptionStatusLoaded) {
                    final subscription = state.subscription;
                    if (subscription != null) {
                      if (subscription.isExpired) {
                        return _buildExpiredSubscription(subscription);
                      } else {
                        return _buildActiveSubscription(subscription);
                      }
                    } else {
                      UserManager.setSubscriptionActive(false);
                      return _buildPlansList(); // No active subscription → show plans
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Expired Subscription UI ----------
  Widget _buildExpiredSubscription(UserSubscription subscription) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/med.svg',
              height: 170,
              width: 170,
              placeholderBuilder: (_) => Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              subscription.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Plan Name', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(subscription.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('₹${subscription.discountPrice}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expired On', style: TextStyle(fontSize: 14, color: Colors.red)),
                    Text(subscription.toDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue, AppColors.blue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stay on Track', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Personalised Care', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                Lottie.asset(
                  'assets/animations/online_doctor.json',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Care Plan Expired', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('₹${subscription.discountPrice}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.blue)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _renewSubscription(subscription),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Renew Care Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------- Active Subscription UI ----------
  Widget _buildActiveSubscription(UserSubscription subscription) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F52A5), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('Active Subscription', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(subscription.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(subscription.duration, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valid From', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(subscription.fromDate, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Valid Until', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(subscription.toDate, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total amount Paid', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('₹${subscription.discountPrice}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Benefits Included', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: subscription.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 20, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(child: Text(benefit, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Subscription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Plan Name', subscription.name),
                  _buildInfoRow('Duration', subscription.duration),
                  _buildInfoRow('Start Date', subscription.fromDate),
                  _buildInfoRow('End Date', subscription.toDate),
                  _buildInfoRow('Amount Paid', '₹${subscription.discountPrice}'),
                  _buildInfoRow('Subscribed On', subscription.createdOn.split(' ')[0]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (subscription.invoice != null && subscription.invoice!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('View Invoice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------- Renew Subscription ----------
  void _renewSubscription(UserSubscription subscription) {
    final plan = SubscriptionPlan(
      id: subscription.id,
      name: subscription.name,
      price: subscription.price.toDouble(),
      discountPrice: subscription.discountPrice.toDouble(),
      duration: subscription.duration,
      benefits: subscription.benefits,
      finalPrice: subscription.discountPrice.toDouble(),
      baseAmount: subscription.price.toDouble(),
      gstAmount: (subscription.discountPrice * 0.18),
      totalAmount: (subscription.discountPrice * 1.18),
      savings: (subscription.price - subscription.discountPrice).toDouble(),
      personsCovered: subscription.name.contains('Family') ? 2 : 1,
      coverageType: 'Family',
    );
    _showPriceBottomSheet(context, plan);
  }

  // ---------- Plans List (Benefits first, then Blue Plans section) ----------
  Widget _buildPlansList() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_subscriptionBloc.state is SubscriptionInitial) {
        _subscriptionBloc.add(LoadSubscriptionPlans());
      }
    });

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionError) {
          showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SubscriptionLoaded) {
          if (state.plans.isEmpty) {
            return const Center(child: Text('No plans available'));
          }

          // Reset selection if needed
          if (_selectedPlanIndex >= state.plans.length) _selectedPlanIndex = 0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== 1. BENEFITS SECTION (White background) ==========
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your MedRayder Benefits",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 18),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _benefitsList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 290,
                          ),
                          itemBuilder: (context, index) {
                            return _buildBenefitCard(_benefitsList[index]);
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // ========== 2. PLANS SECTION (Blue gradient background) ==========
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF0039A6), Color(0xFF0A47C9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Plans For You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Plans cards container
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              children: List.generate(state.plans.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildPremiumPlanCard(
                                    state.plans[index],
                                    index,
                                    isSelected: _selectedPlanIndex == index,
                                    onTap: () {
                                      setState(() {
                                        _selectedPlanIndex = index;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.verified_user,
                                    color: AppColors.blue,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    "Both plans include all MedRayder benefits with 24x7 support.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            height: 66,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () {
                                final selectedPlan = state.plans[_selectedPlanIndex];
                                final paymentPlan = SubscriptionPlan(
                                  id: selectedPlan.id,
                                  name: selectedPlan.name,
                                  price: selectedPlan.price.toDouble(),
                                  discountPrice: selectedPlan.discountPrice.toDouble(),
                                  duration: selectedPlan.duration,
                                  benefits: selectedPlan.benefits,
                                  finalPrice: selectedPlan.discountPrice.toDouble(),
                                  baseAmount: selectedPlan.price.toDouble(),
                                  gstAmount: (selectedPlan.discountPrice * 0.18),
                                  totalAmount: (selectedPlan.discountPrice * 1.18),
                                  savings: (selectedPlan.price - selectedPlan.discountPrice).toDouble(),
                                  personsCovered: selectedPlan.name.contains('Family') ? 2 : 1,
                                  coverageType: selectedPlan.name.contains('Family') ? 'Family' : 'Single',
                                );
                                _showPriceBottomSheet(context, paymentPlan);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/app_logo.png', height: 32),
                                  const SizedBox(width: 14),
                                  Container(width: 1, height: 26, color: Colors.white30),
                                  const SizedBox(width: 14),
                                  const Text(
                                    "Proceed to Pay",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // ========== 3. REVIEWS & FAQS SECTION ==========
                _buildReviewsAndFaqs(),
              ],
            ),
          );
        }

        if (state is SubscriptionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _subscriptionBloc.add(LoadSubscriptionPlans()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

// ================= REVIEWS + FAQS SECTION =================
  Widget _buildReviewsAndFaqs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Reviews ----------
          const Text(
            "What our members say",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReviewCard(
                  name: "Priya Sharma",
                  rating: 5,
                  review:
                  "Amazing value! The family plan saved us thousands on lab tests. The 24/7 doctor helpline is a lifesaver.",
                  date: "2 weeks ago",
                ),
                const SizedBox(width: 16),
                _buildReviewCard(
                  name: "Rahul Mehta",
                  rating: 5,
                  review:
                  "Single plan is perfect for me. Accident cover gave me peace of mind. Customer support is super responsive.",
                  date: "1 month ago",
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ---------- FAQ Section ----------
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildFaqTile(
                    question: "What is the MedRayder 24/7 support?",
                    answer:
                    "MedRayder provides round‑the‑clock expert assistance via call, chat, or email. Whether you need help booking a lab test, understanding your benefits, or claiming insurance, our support team is available anytime.",
                  ),
                  _buildFaqTile(
                    question: "How do I sign up for MedRayder?",
                    answer:
                    "Simply choose your preferred plan (Single or Family) on this page, tap 'Proceed to Pay', complete the secure payment, and your membership activates instantly. You'll receive a confirmation email and SMS.",
                  ),
                  _buildFaqTile(
                    question: "How many plans are there in MedRayder?",
                    answer:
                    "We offer two plans: **Single Care Plan** (for one adult) and **Family Care Plan** (covers two adults). Both include all benefits like doctor consultations, lab test discounts, medicine discounts, and accidental cover.",
                  ),
                  _buildFaqTile(
                    question: "Is 12‑month membership better than other plans?",
                    answer:
                    "Yes! Our annual membership gives you the best value – you pay only ₹100/month for the Single plan or ₹2/day/person for the Family plan. Longer commitment means lower monthly costs and uninterrupted benefits.",
                  ),
                  _buildFaqTile(
                    question: "Can I cancel the membership after purchasing it?",
                    answer:
                    "Memberships are non‑refundable, but you can choose not to renew at the end of your 12‑month term. During the active period, you keep full access to all benefits.",
                  ),
                  _buildFaqTile(
                    question: "Can the offers change after I buy the membership?",
                    answer:
                    "No – once you purchase a plan, the benefits and discounts you signed up for remain locked for the entire 12 months, even if we introduce new offers for new members.",
                  ),
                  _buildFaqTile(
                    question: "How do I redeem my free lab test after buying the plan?",
                    answer:
                    "Open the MedRayder app → go to 'Lab Tests' → select 'Redeem Free Test' → choose your preferred lab partner → show the voucher code at the lab or book online. The free test covers up to 50+ parameters for two adults.",
                  ),
                  _buildFaqTile(
                    question: "Who can redeem the free lab test benefits available with the plan?",
                    answer:
                    "For the **Single Plan**, the primary member can redeem. For the **Family Plan**, both the primary member and their spouse are eligible. Tests must be taken within the active membership period.",
                  ),
                  _buildFaqTile(
                    question: "What is the accidental insurance cover that comes with the Circle plan?",
                    answer:
                    "All MedRayder plans include **₹2,00,000 accidental coverage** for each covered adult. This covers death or permanent disability due to an accident, 24/7 worldwide.",
                  ),
                  _buildFaqTile(
                    question: "Who is eligible to avail the accidental insurance cover?",
                    answer:
                    "All members covered under the plan (primary adult for Single plan; both adults for Family plan) are eligible from the day your membership starts. No medical test required.",
                  ),
                  _buildFaqTile(
                    question: "What is online doctor on call service?",
                    answer:
                    "You get **5 free online doctor consultations** per plan. You can talk to a licensed doctor via video or audio call for general health issues, second opinions, or prescriptions – from the comfort of your home.",
                  ),
                  _buildFaqTile(
                    question: "How can I avail free online doctor on call service?",
                    answer:
                    "In the app, tap 'Online Doctor' → choose 'Online Call' → pick a time slot → connect with a doctor instantly or at your scheduled time. The first 5 consultations are free.",
                  ),
                  _buildFaqTile(
                    question: "Will the lab test be completely free of cost?",
                    answer:
                    "The annual free lab test (50+ parameters) is **100% free** – no hidden charges. Additional tests beyond the free package get up to 70% discount.",
                  ),
                  _buildFaqTile(
                    question: "What is the process to claim accidental insurance cover?",
                    answer:
                    " Contact Acko (our insurance partner) directly. You can reach their claims team via the Acko app or call their 24/7 claims support number. They will guide you through the simple process with minimal documentation."                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Single review card widget
  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String review,
    required String date,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: const TextStyle(fontSize: 13, height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

// Expandable FAQ tile (using built-in ExpansionTile)
  Widget _buildFaqTile({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  // ---------- Premium plan card with selection highlight ----------
  Widget _buildPremiumPlanCard(SubscriptionPlan plan, int index, {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: isSelected ? Border.all(color: AppColors.blue, width: 2) : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade50,
              ),
              child: Icon(
                plan.name.contains('Family') ? Icons.family_restroom : Icons.person,
                color: AppColors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ${plan.name}",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${plan.discountPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.discountPrice <= 1500
                        ? "Only ₹100/month"
                        : "Only ₹2/day /person",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Radio / Selection indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: AppColors.blue,
              size: 34,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Benefits list data ----------
  final List<Map<String, dynamic>> _benefitsList = [
    {
      "title": "Doctor Consultations",
      "image": "assets/medical.png",
      "points": [
        "5 Free consultations",
        "Offline & Online doctor consultations",
        "Video/Audio Call with Experienced Doctors",
        "No hidden charges",
      ]
    },
    {
      "title": "Health Check-up",
      "image": "assets/profile.png",
      "points": [
        "Full Body Check-up",
        "52 Parameters Covered",
        "Annual health insights",
      ]
    },
    {
      "title": "Accidental Insurance",
      "image": "assets/health_insurance.png",
      "points": [
        "₹2 Lakh accidental cover",
        "Financial protection for you & your family",
      ]
    },
    {
      "title": "Medicine Discount",
      "image": "assets/medicine.png",
      "points": [
        "20% discount on all medicines",
        "Genuine medicines",
        "Delivered to your door",
      ]
    },
    {
      "title": "Lab & Diagnostic Tests",
      "image": "assets/laboratory.png",
      "points": [
        "Upto 70% off on all lab & diagnostic tests",
        "Wide range of tests",
        "Accurate reports",
      ]
    },
    {
      "title": "Customer Support",
      "image": "assets/support.png",
      "points": [
        "24/7 expert support",
        "Quick help, always",
        "Assistance in every step",
      ]
    },
  ];

  // ---------- Benefit card widget ----------
  Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Container(
            height: 95,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0046C0), Color(0xFF005BFF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                benefit['image'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, color: Colors.white, size: 40);
                },
              ),
            ),
          ),
          // TITLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(color: Color(0xFF032C76)),
            child: Text(
              benefit['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: List.generate(
                    benefit['points'].length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(Icons.check_circle, color: AppColors.blue, size: 16),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              benefit['points'][index],
                              style: const TextStyle(fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Payment Bottom Sheet ----------
  void _showPriceBottomSheet(BuildContext context, SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return BlocProvider.value(
          value: _paymentBloc,
          child: BlocConsumer<SubscriptionPaymentBloc, SubscriptionPaymentState>(
            listener: (context, state) {
              if (state is SubscriptionPaymentOrderCreated) {
                Navigator.pop(context);
                _openCashfreeCheckout(context, state.order, state.subscriptionId, _paymentBloc);
              } else if (state is SubscriptionPaymentError) {
                Navigator.pop(context);
                showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: AppColors.black)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Plan', plan.name),
                    _buildDetailRow('Subtotal', '₹${plan.finalPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Persons Covered', plan.personsCovered.toString()),
                    _buildDetailRow('GST (18%)', '₹${plan.gstAmount.toStringAsFixed(2)}'),
                    const Divider(height: 32, thickness: 1),
                    _buildDetailRow('Total Amount', '₹${plan.totalAmount.toStringAsFixed(2)}', isTotal: true),
                    const SizedBox(height: 24),
                    state is SubscriptionPaymentLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _paymentBloc.add(CreateSubscriptionPaymentOrder(plan.totalAmount.ceil(), plan.id));
                        },
                        child: const Text('Subscribe Now', style: TextStyle(color: AppColors.whiteColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openCashfreeCheckout(BuildContext context, SubscriptionOrder order, int subscriptionId, SubscriptionPaymentBloc bloc) {
    final cashfree = sl.sl<CashfreeService>();
    cashfree.startPayment(
      orderId: order.orderId,
      paymentSessionId: order.paymentSessionId,
      environment: CFEnvironment.PRODUCTION,
      onSuccess: (orderId) => bloc.add(ConfirmSubscriptionPayment(orderId, subscriptionId)),
      onFailure: (error) => showErrorSnackBar(error),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Poppins', color: AppColors.black)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, fontFamily: 'Poppins', color: AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
