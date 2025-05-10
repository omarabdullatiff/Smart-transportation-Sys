#!/bin/bash

# Move core files
mv lib/app_color.dart lib/core/constants/app_colors.dart
mv lib/routes.dart lib/core/routes/app_routes.dart
mv lib/loading_screen.dart lib/core/utils/loading_screen.dart

# Move auth related files
mv lib/login.dart lib/features/auth/screens/login_screen.dart
mv lib/signup.dart lib/features/auth/screens/signup_screen.dart
mv lib/forget_pass.dart lib/features/auth/screens/forget_password_screen.dart
mv lib/change_pass.dart lib/features/auth/screens/change_password_screen.dart
mv lib/verification_screen.dart lib/features/auth/screens/verification_screen.dart

# Move bus related files
mv lib/BusList.dart lib/features/bus/screens/bus_list_screen.dart
mv lib/map.dart lib/features/bus/screens/bus_tracking_screen.dart
mv lib/seat_select_screan.dart lib/features/bus/screens/seat_selection_screen.dart

# Move booking related files
mv lib/BookingScreen.dart lib/features/booking/screens/booking_screen.dart
mv lib/selectaddress.dart lib/features/booking/screens/select_address_screen.dart

# Move lost items related files
mv lib/loses.dart lib/features/lost_items/screens/lost_items_screen.dart
mv lib/found_items.dart lib/features/lost_items/screens/found_items_screen.dart

# Move profile related files
mv lib/profilescreen.dart lib/features/profile/screens/profile_screen.dart
mv lib/setting_screen.dart lib/features/profile/screens/settings_screen.dart

# Move component files
mv lib/component.dart lib/shared/widgets/common_widgets.dart 