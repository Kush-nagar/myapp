# Store It Feature Documentation

## Overview

The **Store It** feature is an AI-powered storage tips and recommendations system that helps users maximize the shelf life and maintain the quality of their detected ingredients. It leverages Google's Gemini AI to provide personalized, comprehensive storage guidance.

## Features

### 🎯 Core Functionality

- **AI-Powered Analysis**: Uses Google Gemini API to analyze detected ingredients
- **Comprehensive Storage Tips**: Provides detailed storage recommendations for each ingredient
- **Professional UI**: Clean, aesthetic interface with tabbed navigation
- **Category-Based Tips**: Organizes advice by food categories (vegetables, fruits, proteins, etc.)
- **Environmental Factors**: Guidance on optimal temperature, humidity, light, and airflow
- **Food Safety**: Critical safety reminders and warnings

### 📱 User Interface

- **Tabbed Navigation**: 4 main sections (Overview, Detailed, By Category, Advanced)
- **Interactive Cards**: Expandable storage tip cards with detailed information
- **Visual Indicators**: Color-coded priority system based on shelf life urgency
- **Loading Animations**: Professional loading states with progress indicators
- **Error Handling**: Graceful error states with retry functionality

### 🔧 Technical Features

- **Service Architecture**: Modular StorageTipsService for API communication
- **Widget System**: Reusable, modular widgets for different tip types
- **Animation Support**: Smooth transitions and loading animations
- **Responsive Design**: Optimized for different screen sizes using Sizer package

## Setup Instructions

### 1. API Key Configuration

To use the Store It feature, you need a Google Gemini API key:

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Replace the placeholder in `/lib/presentation/store_it_screen/store_it_screen.dart`:

```dart
// TODO: Replace with your actual Gemini API key
const apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### 2. Dependencies

The feature uses the following packages (already included in pubspec.yaml):

- `http`: For API communication
- `sizer`: For responsive design
- `flutter/material.dart`: For UI components

### 3. Navigation Setup

The feature is already integrated into the app's routing system:

- Route: `/store-it-screen`
- Access from: Recognition Results Screen → "Store It" button

## Usage

### From Recognition Results Screen

1. Detect ingredients using the camera feature
2. View results in Recognition Results Screen
3. Tap the "Store It" button
4. Navigate to the Store It screen with detected ingredients

### API Integration

The `StorageTipsService` provides two main methods:

#### Comprehensive Storage Tips

```dart
Future<Map<String, dynamic>> generateStorageTips(List<String> ingredients)
```

Returns a complete storage analysis including:

- General storage principles
- Item-specific detailed tips
- Category-based recommendations
- Environmental factors
- Extended shelf life techniques
- Food safety guidelines

#### Quick Storage Tips

```dart
Future<List<Map<String, dynamic>>> generateQuickTips(List<String> ingredients)
```

Returns immediate, actionable storage advice for urgent use.

## File Structure

```
lib/presentation/store_it_screen/
├── store_it_screen.dart                 # Main screen implementation
└── widgets/
    ├── loading_storage_tips_widget.dart # Loading animation widget
    ├── storage_tip_card_widget.dart     # Individual tip card
    ├── quick_tips_widget.dart           # Quick tips section
    ├── category_tips_widget.dart        # Category-based tips
    └── environmental_factors_widget.dart # Environmental conditions

lib/services/
└── storage_tips_service.dart            # API service layer
```

## Widget Documentation

### LoadingStorageTipsWidget

- Animated loading state with rotating icon
- Progress indicator
- Skeleton cards for better UX
- Professional animations using AnimationController

### StorageTipCardWidget

- Expandable cards for detailed ingredient information
- Color-coded priority system
- Icons for different storage methods
- Animated expansion/collapse

### QuickTipsWidget

- Overview of general storage principles
- Numbered tips with professional styling
- Pro tip callouts

### CategoryTipsWidget

- Food category-specific storage advice
- Category-specific icons and colors
- Clean, organized presentation

### EnvironmentalFactorsWidget

- Grid layout for environmental conditions
- Visual representations with icons
- Temperature, humidity, light, and airflow guidance

## Customization

### Styling

The feature uses the app's existing theme system:

- `AppTheme.lightTheme` for consistent styling
- Color scheme integration
- Typography system compliance

### API Configuration

Modify the `StorageTipsService` constructor for:

- Different AI models
- Custom prompt templates
- Response processing logic

### UI Customization

Each widget is modular and can be customized:

- Color schemes
- Layout arrangements
- Animation timings
- Content organization

## Error Handling

The feature includes comprehensive error handling:

- Network connectivity issues
- API response errors
- Malformed data handling
- User-friendly error messages
- Retry functionality

## Performance Considerations

- Efficient API calls with single requests
- Lazy loading of widget content
- Optimized animations
- Memory-conscious image handling
- Responsive design for various screen sizes

## Future Enhancements

Potential improvements for the Store It feature:

- Offline storage tips database
- User favorites and bookmarking
- Push notifications for expiry reminders
- Integration with shopping lists
- Community-contributed tips
- Multi-language support
- Voice guidance
- Barcode scanning integration

## Troubleshooting

### Common Issues

1. **API Key Issues**

   - Ensure the API key is valid and active
   - Check API quotas and usage limits
   - Verify network connectivity

2. **Loading Issues**

   - Check internet connection
   - Verify ingredient data format
   - Review error logs for API responses

3. **UI Issues**
   - Ensure all widget dependencies are imported
   - Check theme consistency
   - Verify responsive design on different screens

### Debug Mode

For development, enable detailed logging in `StorageTipsService`:

```dart
// Add debug prints in service methods
print('Request payload: $body');
print('API response: ${resp.body}');
```

## Contributing

When contributing to the Store It feature:

1. Follow existing code patterns
2. Maintain widget modularity
3. Update documentation
4. Test on multiple screen sizes
5. Ensure accessibility compliance
6. Add appropriate error handling

## API Reference

### Request Format

The service sends structured prompts to Gemini API requesting JSON responses with specific schemas for different tip types.

### Response Processing

- JSON parsing with fallback mechanisms
- Error handling for malformed responses
- Data validation and sanitization
- Type safety enforcement

### Rate Limiting

Be mindful of API rate limits and implement appropriate throttling for production use.

---

_This feature enhances the food recognition app by providing valuable storage guidance, helping users reduce food waste and maintain ingredient quality._
