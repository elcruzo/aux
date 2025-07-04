# Contributing to Aux

First off, thank you for considering contributing to Aux! It's people like you that make Aux such a great tool for music lovers everywhere.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible using our bug report template.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Create an issue using the feature request template and provide as much detail as possible.

### Your First Code Contribution

Unsure where to begin contributing to Aux? You can start by looking through these `beginner` and `help-wanted` issues:

* [Beginner issues](https://github.com/elcruzo/aux/labels/beginner) - issues which should only require a few lines of code
* [Help wanted issues](https://github.com/elcruzo/aux/labels/help%20wanted) - issues which should be a bit more involved

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing style
6. Issue that pull request!

## Development Setup

### Prerequisites

- Node.js 18+ and npm
- Xcode 15+ (for iOS development)
- Apple Developer account (for Apple Music integration)
- Spotify Developer account (for Spotify integration)

### iOS Development

1. Clone the repository
```bash
git clone https://github.com/elcruzo/aux.git
cd aux/aux-app
```

2. Install dependencies
```bash
npm install
```

3. Set up iOS project
```bash
cd src/app/ios/Aux
cp Aux/Config.xcconfig.example Aux/Configuration.xcconfig
# Edit Configuration.xcconfig with your API keys
```

4. Open in Xcode
```bash
open Aux.xcodeproj
```

### Backend Development

1. Set up environment variables
```bash
cp .env.example .env.local
# Edit .env.local with your credentials
```

2. Run development server
```bash
npm run dev
```

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### Swift Style Guide

* Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
* Use SwiftUI for all new UI code
* Ensure all UI supports dark mode
* No hardcoded colors or strings

### TypeScript Style Guide

* Use TypeScript for all new code
* Follow the existing code style
* Add types for all function parameters and return values
* Document complex functions with JSDoc comments

### UI/UX Guidelines

* All UI must support both light and dark modes
* Use system colors and adaptive colors from asset catalogs
* Follow iOS Human Interface Guidelines
* Test on multiple device sizes

## Testing

### iOS Testing
- Test on both simulator and real devices
- Test Share Extension functionality
- Test with both Spotify and Apple Music
- Test in both light and dark mode
- Test offline scenarios

### API Testing
- Test all endpoints with valid and invalid data
- Test authentication flows
- Test rate limiting and error scenarios
- Ensure proper error messages

## Questions?

Feel free to open an issue with the question label or reach out to [ayomideadekoya266@gmail.com](mailto:ayomideadekoya266@gmail.com).