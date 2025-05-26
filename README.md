# Order Inbox - AI-Powered Sales Rep Order Management

A comprehensive Flutter application designed for sales representatives to efficiently manage orders from multiple channels using on-device AI capabilities.

## Features

### 🤖 AI-Powered Order Processing
- **Image Enhancement**: Automatic blur/brightness detection and correction for better OCR results
- **OCR Text Recognition**: Extract text from images with bounding box detection and confidence scores
- **Speech-to-Text**: Convert voice recordings to text for order processing
- **Smart Order Formatting**: AI-powered extraction of SKU names, quantities, and customer information

### 📱 Multi-Channel Order Input
- **Camera Capture**: Real-time camera interface for scanning order documents
- **Gallery Import**: Process existing images from device gallery
- **Voice Recording**: Record and process voice orders
- **Manual Entry**: Direct text input for quick order creation
- **WhatsApp/Email Integration**: Ready for future integration with messaging platforms

### 🎯 Interactive Order Management
- **Bounding Box Visualization**: See exactly where text was detected in images
- **Confidence Scores**: View AI confidence levels for each detected item
- **Tap-to-Correct**: Easy correction interface for improving AI accuracy
- **Continual Learning**: User corrections feed back into the system for better future performance

### 📊 Order Tracking & Analytics
- **Order Status Management**: Track orders from pending to completion
- **Customer Information**: Store and manage customer details
- **Order History**: Complete audit trail of all orders
- **Analytics Dashboard**: Overview of order statistics and trends

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **Go Router**: Navigation and routing
- **Material Design 3**: Modern UI components

### AI & ML
- **Google ML Kit**: On-device text recognition and image labeling
- **Speech-to-Text**: Voice recognition capabilities
- **Image Processing**: Custom image enhancement algorithms
- **TensorFlow Lite**: On-device machine learning (ready for custom models)

### Data & Storage
- **SQLite**: Local database for order storage
- **Shared Preferences**: App settings and preferences
- **File System**: Image and audio file management

### Media Handling
- **Camera**: Real-time camera capture
- **Image Picker**: Gallery and camera integration
- **Audio Recording**: Voice capture and processing
- **Permission Handler**: Runtime permission management

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS development tools (for iOS deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd order_inbox
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Permissions Required
- **Camera**: For capturing order images
- **Microphone**: For voice order recording
- **Storage**: For saving and accessing images
- **Photos**: For gallery access

## App Architecture

### Directory Structure
```
lib/
├── models/           # Data models (Order, OrderItem, BoundingBox)
├── services/         # Business logic (AI, Database)
├── providers/        # State management (Order, AI, Media)
├── screens/          # UI screens (Home, Camera, Order Details, Settings)
├── widgets/          # Reusable UI components
└── utils/            # Helper functions and utilities
```

### Key Components

#### AI Service (`lib/services/ai_service.dart`)
- Image quality assessment and enhancement
- OCR text recognition with bounding boxes
- Speech-to-text conversion
- Order information extraction and formatting

#### Database Service (`lib/services/database_service.dart`)
- SQLite database management
- Order CRUD operations
- User correction tracking
- Analytics data aggregation

#### Order Provider (`lib/providers/order_provider.dart`)
- Order state management
- Database interaction coordination
- Error handling and loading states

#### Media Provider (`lib/providers/media_provider.dart`)
- Camera and gallery access
- Audio recording management
- File handling and cleanup

## Usage Guide

### Creating Orders

1. **Camera Capture**
   - Tap "Camera" on the home screen
   - Point camera at order document
   - Tap capture button
   - AI will process the image and extract order information

2. **Voice Recording**
   - Tap "Voice" on the home screen
   - Speak your order clearly
   - Tap "Stop & Process" when finished
   - AI will convert speech to text and format the order

3. **Gallery Import**
   - Tap "Gallery" on the home screen
   - Select an image from your device
   - AI will process the image for order information

4. **Manual Entry**
   - Tap "Manual" on the home screen
   - Type the order information
   - AI will parse and format the text

### Managing Orders

- **View Orders**: All orders appear on the home screen with status indicators
- **Edit Orders**: Tap any order to view details and make corrections
- **Update Status**: Mark orders as completed or cancelled
- **Correct AI Results**: Tap on any detected item to correct information

### AI Correction & Learning

- When AI makes mistakes, tap the incorrect item to edit it
- Your corrections are saved and help improve future AI performance
- Confidence scores show how certain the AI is about each detection
- Low confidence items are highlighted for review

## Customization

### AI Model Configuration
- Adjust OCR confidence thresholds in settings
- Enable/disable automatic image enhancement
- Configure speech recognition language

### UI Customization
- Modern Material Design 3 theming
- Customizable color schemes
- Responsive layout for different screen sizes

## Future Enhancements

### Planned Features
- **WhatsApp Integration**: Direct order processing from WhatsApp messages
- **Email Integration**: Process orders from email attachments
- **Custom AI Models**: Train models specific to your product catalog
- **Cloud Sync**: Backup and sync orders across devices
- **Advanced Analytics**: Detailed reporting and insights
- **Multi-language Support**: Support for multiple languages
- **Barcode Scanning**: Quick product identification via barcodes

### Technical Improvements
- **On-device LLM**: Advanced natural language processing
- **Real-time Collaboration**: Multi-user order management
- **Offline Sync**: Work offline with automatic sync when connected
- **Advanced Image Processing**: Better handling of poor quality images

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@orderinbox.com or create an issue in the repository.

## Acknowledgments

- Google ML Kit for on-device AI capabilities
- Flutter team for the excellent framework
- Material Design team for the beautiful design system
