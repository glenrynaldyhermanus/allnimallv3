import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../widgets/pet_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();

    // Force refresh pets provider when dashboard mounts
    // Add delay to ensure database transaction completes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Wait 1 second for database to fully commit
      await Future.delayed(const Duration(seconds: 1));

      // Check if widget is still mounted before using ref
      if (!mounted) return;

      final authUser = ref.read(authStateChangesProvider).value;
      if (authUser != null) {
        print('🔄 Force invalidating petsByOwnerProvider after delay');
        ref.invalidate(petsByOwnerProvider(authUser.id));
      }
    });
  }

  Future<void> _loadPhoneNumber() async {
    // Get phone from Firebase Auth directly (bypass customer check)
    final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
    final firebaseUser = await firebaseDataSource.getCurrentFirebaseUser();

    if (!mounted) return;

    if (firebaseUser != null && firebaseUser.phoneNumber != null) {
      setState(() {
        _phoneNumber = firebaseUser.phoneNumber;
      });
    } else {
      // Fallback: No Firebase user, redirect to login
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.myPets,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final signOut = ref.read(signOutUseCaseProvider);
              await signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: _phoneNumber == null
          ? const Center(child: LoadingIndicator())
          : _buildCustomerAndPets(context, ref, _phoneNumber!),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.petNew);
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addPet),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildCustomerAndPets(
    BuildContext context,
    WidgetRef ref,
    String phoneNumber,
  ) {
    final getCustomerUseCase = ref.read(getCustomerByPhoneUseCaseProvider);
    final customerFuture = getCustomerUseCase(phoneNumber);

    return FutureBuilder(
      future: customerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState(
            message: 'Failed to load customer: ${snapshot.error}',
            onRetry: () {
              // Retry by rebuilding
              setState(() {});
            },
          );
        }

        final customer = snapshot.data?.fold(
          (failure) => null,
          (customer) => customer,
        );

        if (customer == null) {
          // Customer doesn't exist, redirect to profile setup
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('${AppRoutes.userNew}?from=verify-otp');
            }
          });
          return const Center(child: LoadingIndicator());
        }

        // Check if customer name is empty (new user needs profile setup)
        // Firebase users have null name initially
        if (customer.name == null || customer.name!.trim().isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('${AppRoutes.userNew}?from=verify-otp');
            }
          });
          return const Center(child: LoadingIndicator());
        }

        return _buildPetsList(context, ref, customer.id);
      },
    );
  }

  Widget _buildPetsList(BuildContext context, WidgetRef ref, String ownerId) {
    final petsAsync = ref.watch(petsByOwnerProvider(ownerId));

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          // Redirect to user/new if no pets (auto UX)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.userNew);
            }
          });
          return const Center(child: LoadingIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(petsByOwnerProvider(ownerId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return PetCard(
                pet: pet,
                onTap: () {
                  context.push(AppRoutes.pet.replaceAll(':petId', pet.id));
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.refresh(petsByOwnerProvider(ownerId)),
      ),
    );
  }
}
