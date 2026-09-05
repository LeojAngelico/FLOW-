/// The vocabulary [UserProfile], `HydrationInputs` and the onboarding
/// draft all share.
///
/// Split into its own file, with **no imports at all**, so that
/// `features/hydration/calculator/` — which must have zero dependencies
/// on Flutter, Riverpod, Drift or any other feature (`07 §5`) — can
/// import just the enums it needs without pulling in `user_profile.dart`
/// and whatever that file eventually depends on. See
/// `docs/workplans/2026-09-05-onboarding.md` Decisions #2.
library;

/// `user_profiles.sex`. `preferNotToSay` resolves to the female baseline
/// in the hydration calculator (`BR-42`) — it is a privacy choice, not a
/// third biological category the algorithm's tables need their own
/// column for.
enum Sex { female, male, preferNotToSay }

/// `user_profiles.activity_level`. Declaration order matches `ONB-05`'s
/// five `ChoiceCard`s and the calculator's ascending delta table
/// (`08 §6.2` step 3).
enum ActivityLevel { sedentary, light, moderate, high, athlete }

/// `user_profiles.environment` (`08 §6.2` step 4).
enum Environment { temperate, warm, hot, veryHot }

/// `user_profiles.special_circumstances`. Encoded as a comma-joined
/// string in **this declaration order** by
/// `features/onboarding/data/models/user_profile_mapper.dart`, so the
/// same selection always produces the same string regardless of the
/// order the user tapped them in.
enum SpecialCircumstance { pregnancy, breastfeeding, medicalCondition, other }

/// `user_profiles.target_source` — whether `dailyTargetMl` came from the
/// calculator (`ONB-07` Accept) or a manual edit (Adjust), driving
/// `FR-101`'s re-suggestion behaviour.
enum TargetSource { suggested, manual }
