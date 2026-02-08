# BC Launch Profile

Quick and easy switching between Business Central environments in your `launch.json` configuration. Perfect for consultants and developers who work with multiple clients and environments.

## Features

- **Quick Profile Switching**: Right-click in your `launch.json` and select "Apply BC Launch Profile"
- **Duplicate & Apply**: Create a copy of your configuration with a different profile in one step
- **Centralized Configuration**: Manage all your BC environments in a single `bclaunchprofiles.json` file
- **Multi-Client Support**: Easily handle multiple clients with different tenants and environments
- **Visual Selection**: Pick profiles from a searchable list with environment details
- **Smart Detection**: Automatically detects which configuration to update based on cursor position
- **Automatic Updates**: Instantly updates `environmentType`, `environmentName`, `tenant`, and configuration name

## Usage

1. Create a `bclaunchprofiles.json` file in your workspace root:

```json
{
  "profiles": [
    {
      "name": "TechCorp Innovation - Production",
      "environmentType": "Sandbox",
      "environmentName": "TECHCORP-PROD",
      "tenant": "a1b2c3d4-1111-2222-3333-444455556666"
    },
    {
      "name": "TechCorp Innovation - QA/Testing",
      "environmentType": "Sandbox",
      "environmentName": "TECHCORP-QA",
      "tenant": "a1b2c3d4-1111-2222-3333-444455556666"
    },
    {
      "name": "GreenEnergy Solutions - Production",
      "environmentType": "Sandbox",
      "environmentName": "GREENENERGY-PROD",
      "tenant": "b2c3d4e5-2222-3333-4444-555566667777"
    }
  ]
}
```

2. Open your `launch.json` file
3. Place your cursor inside the configuration you want to update
4. Right-click and choose one of:
   - **"Apply BC Launch Profile"** - Updates the current configuration
   - **"Duplicate Configuration & Apply BC Profile"** - Creates a copy with the new profile
5. Select your desired environment from the searchable list

The extension automatically detects which configuration to update based on your cursor position.

## Requirements

- Visual Studio Code 1.85.0 or higher
- A `bclaunchprofiles.json` file in your workspace root
- AL Language extension (for Business Central development)

## Extension Settings

This extension does not require any additional settings. Just create your `bclaunchprofiles.json` and you're ready to go!

## Tips

- **Organize by Client**: Use clear naming conventions like `ClientName - Environment` to easily filter profiles
- **Search**: The profile picker is searchable - type to filter by client name, environment type, or tenant
- **Multiple Clients**: All environments for the same client should share the same tenant ID

## Release Notes

### 1.0.0

Initial release of BC Launch Profile

- Quick profile switching functionality
- Duplicate and apply configuration feature
- Context menu integration
- Smart configuration detection based on cursor position
- Support for multiple clients and environments

---

## 📄 License

[MIT License](https://github.com/gdrgdev/Blog/tree/main/GDRGDev_VSCALBCLaunchProfile/License.txt) - Gerardo Rentería

## 🤝 Contributions

Contributions welcome! Visit the [source code](https://github.com/gdrgdev/Blog/tree/main/GDRGDev_VSCALBCLaunchProfile) on my blog.

## ⭐ ¿Te resultó útil? 

Dale una estrella al [repositorio](https://github.com/gdrgdev/Blog)!

**Enjoy!**
