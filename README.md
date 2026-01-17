# Invoice Generator App

A professional Flutter application for creating, managing, and sharing invoices with PDF export capabilities.

## Features

### 📊 Dashboard & Analytics

- Real-time statistics (total invoices, revenue, paid/unpaid/overdue counts)
- Beautiful gradient stat cards with icons
- Quick overview of business performance

### 📝 Invoice Management

- Create and edit invoices with ease
- Auto-generated invoice numbering (INV-0001, INV-0002, etc.)
- Dynamic item list with real-time calculations
- Tax and discount support
- Multiple currency support (USD, EUR, GBP, MXN)
- Search and filter invoices by status
- Mark invoices as paid/unpaid
- Duplicate existing invoices
- Delete invoices with confirmation

### 👥 Customer Management

- Add, edit, and delete customers
- Complete customer information (name, email, phone, address)
- Search customers
- Customer selection in invoice forms

### 📄 PDF Generation

- Professional invoice PDF generation
- Company branding and logo support
- Itemized billing with tax calculations
- Preview PDF before sharing
- Share invoices via email, messaging, etc.

### ⚙️ Settings

- Company information management
- Business address and contact details
- Tax ID and registration number
- Default currency and tax rate settings
- Modern, intuitive interface

### 🎨 Modern UI/UX

- Material Design 3
- Light and dark mode support
- Google Fonts (Inter & Poppins)
- Smooth animations and transitions
- Responsive layouts
- Professional color scheme

## Installation

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Setup

1. Clone the repository:

```bash
cd /home/marvin/workspace/flutter/invoice_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Usage

### First Time Setup

1. Launch the app
2. Go to Settings (gear icon in top right)
3. Enter your company information
4. Set default currency and tax rate

### Creating Your First Invoice

1. Tap the "New Invoice" button on the home screen
2. Add or select a customer
3. Set invoice and due dates
4. Add line items with descriptions, quantities, and prices
5. Apply tax percentages and discounts as needed
6. Add optional notes
7. Tap "Save Invoice"

### Managing Customers

1. Tap the people icon in the top right
2. Tap "Add Customer" to create a new customer
3. Fill in customer details
4. Save the customer

### Generating PDFs

1. Open an invoice from the list
2. Tap "View PDF" to preview
3. Tap "Share" to send via email or other apps

## Project Structure

```
lib/
├── models/           # Data models (Invoice, Customer, Company, InvoiceItem)
├── screens/          # UI screens (Home, InvoiceForm, InvoiceDetail, Customers, Settings)
├── services/         # Business logic (DatabaseService, InvoiceService, PdfService)
├── theme/            # App theme and styling
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## Dependencies

- **hive & hive_flutter**: Local database storage
- **pdf**: PDF document generation
- **printing**: PDF preview and printing
- **intl**: Date and number formatting
- **google_fonts**: Modern typography
- **share_plus**: Share functionality
- **uuid**: Unique ID generation
- **path_provider**: File system access

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## License

This project is open source and available for personal and commercial use.

## Support

For issues, questions, or feature requests, please create an issue in the repository.

---

**Built with Flutter** 💙
