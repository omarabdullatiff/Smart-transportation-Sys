# Reusable Components Guide

This directory contains reusable UI components that can be used throughout the Flutter application to maintain consistency and reduce code duplication.

## Available Components

### 1. CustomTextField
A comprehensive text field widget with password visibility toggle, validation, and various styling options.

#### Basic Usage:
```dart
CustomTextField(
  controller: emailController,
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
)
```

#### Password Field:
```dart
CustomTextField(
  controller: passwordController,
  label: 'Password',
  hint: 'Enter password',
  isPassword: true,
  prefixIcon: Icons.lock,
)
```

#### With Validation:
```dart
CustomTextField(
  controller: nameController,
  label: 'Name',
  hint: 'Enter your name',
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Name is required';
    return null;
  },
)
```

### 2. CustomButton
A versatile button widget with different types, loading states, and styling options.

#### Button Types:
```dart
// Primary button
CustomButton(
  text: 'Submit',
  onPressed: () {},
)

// Secondary button
CustomButton(
  text: 'Cancel',
  type: ButtonType.secondary,
  onPressed: () {},
)

// Outline button
CustomButton(
  text: 'Learn More',
  type: ButtonType.outline,
  onPressed: () {},
)

// Text button
CustomButton(
  text: 'Skip',
  type: ButtonType.text,
  onPressed: () {},
)

// Danger button
CustomButton(
  text: 'Delete',
  type: ButtonType.danger,
  onPressed: () {},
)
```

#### With Loading State:
```dart
CustomButton(
  text: 'Login',
  isLoading: isLoading,
  onPressed: isLoading ? null : _handleLogin,
)
```

#### With Icon:
```dart
CustomButton(
  text: 'Add Item',
  icon: Icons.add,
  onPressed: () {},
)
```

### 3. CustomCard
A flexible card widget with different types and styling options.

#### Basic Card:
```dart
CustomCard(
  child: Text('Card content'),
)
```

#### Specialized Cards:
```dart
// Stat Card
StatCard(
  title: 'Total Users',
  value: '1,234',
  icon: Icons.people,
  color: Colors.blue,
)

// Action Card
ActionCard(
  title: 'Create New',
  icon: Icons.add,
  color: Colors.green,
  onTap: () {},
)

// Info Card
InfoCard(
  title: 'John Doe',
  subtitle: 'Software Developer',
  leading: CircleAvatar(child: Text('JD')),
  trailing: Icon(Icons.arrow_forward),
  onTap: () {},
)
```

### 4. CustomDialog
Utility class for showing various types of dialogs.

#### Confirmation Dialog:
```dart
final confirmed = await CustomDialog.showConfirmation(
  context: context,
  title: 'Delete Item',
  message: 'Are you sure you want to delete this item?',
  confirmText: 'Delete',
  confirmType: ButtonType.danger,
);

if (confirmed == true) {
  // Handle deletion
}
```

#### Info Dialog:
```dart
await CustomDialog.showInfo(
  context: context,
  title: 'Success',
  message: 'Operation completed successfully!',
  icon: Icons.check_circle,
  iconColor: Colors.green,
);
```

#### Form Dialog:
```dart
showDialog(
  context: context,
  builder: (context) => FormDialog(
    title: 'Add User',
    fields: [
      CustomTextField(
        controller: nameController,
        label: 'Name',
        hint: 'Enter name',
      ),
      CustomTextField(
        controller: emailController,
        label: 'Email',
        hint: 'Enter email',
      ),
    ],
    onSave: () {
      // Handle save
      Navigator.pop(context);
    },
  ),
);
```

#### List Dialog:
```dart
final items = [
  ListDialogItem(title: 'Option 1', value: 1),
  ListDialogItem(title: 'Option 2', value: 2),
];

showDialog(
  context: context,
  builder: (context) => ListDialog<int>(
    title: 'Select Option',
    items: items,
    onItemSelected: (value) {
      // Handle selection
    },
  ),
);
```

### 5. CustomSnackBar
Enhanced snackbar with different types and better styling.

#### Basic Usage:
```dart
CustomSnackBar.showSuccess(
  context: context,
  message: 'Operation successful!',
);

CustomSnackBar.showError(
  context: context,
  message: 'Something went wrong!',
);

CustomSnackBar.showWarning(
  context: context,
  message: 'Please check your input.',
);

CustomSnackBar.showInfo(
  context: context,
  message: 'Information message.',
);
```

#### With Action:
```dart
CustomSnackBar.showError(
  context: context,
  message: 'Failed to save',
  actionLabel: 'Retry',
  onAction: () {
    // Handle retry
  },
);
```

### 6. LoadingWidget
Versatile loading indicators with different animations.

#### Basic Loading:
```dart
LoadingWidget(
  message: 'Loading data...',
)
```

#### Different Types:
```dart
// Circular (default)
LoadingWidget(type: LoadingType.circular)

// Linear progress
LoadingWidget(type: LoadingType.linear)

// Animated dots
LoadingWidget(type: LoadingType.dots)

// Wave animation
LoadingWidget(type: LoadingType.wave)
```

#### Full Screen Loading:
```dart
// Show loading overlay
LoadingOverlay.show(context, message: 'Processing...');

// Hide loading overlay
LoadingOverlay.hide(context);
```

#### Page Loading:
```dart
// For entire page loading state
return PageLoading(message: 'Loading page...');
```

## Best Practices

### 1. Consistency
- Always use these reusable components instead of creating custom widgets
- Maintain consistent styling across the app
- Use the same color schemes and typography

### 2. Accessibility
- All components include proper accessibility features
- Use semantic labels and descriptions
- Support screen readers and keyboard navigation

### 3. Performance
- Components are optimized for performance
- Use const constructors where possible
- Minimize rebuilds with proper state management

### 4. Customization
- Components are highly customizable through parameters
- Override default styles when needed for specific use cases
- Extend components for complex requirements

### 5. Error Handling
- Always handle loading states properly
- Show appropriate error messages using CustomSnackBar
- Use validation in forms with CustomTextField

## Example Implementation

Here's a complete example of how to use multiple components together:

```dart
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      CustomSnackBar.showSuccess(
        context: context,
        message: 'Data saved successfully!',
      );
    } catch (e) {
      CustomSnackBar.showError(
        context: context,
        message: 'Failed to save data',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomCard(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Enter your name',
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'Submit',
                    width: double.infinity,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This approach ensures consistent UI, reduces code duplication, and makes the app easier to maintain and update. 