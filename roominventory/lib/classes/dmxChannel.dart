/// Represents a DMX channel with its configuration and connection information.
///
/// A DMX channel can be either a stage fixture (FX) or a DMX output channel.
/// This class encapsulates all the properties needed to manage and display
/// channel information in the DMX configuration system.
///
/// ## Properties:
/// - [id]: Unique identifier for the channel
/// - [position]: Physical/Logical position identifier (e.g., "FX_A1", "DMX_R1_1")
/// - [type]: Type of channel (Fixture or DMX output)
/// - [state]: Current connection state (disconnected, connected, or broken)
/// - [connections]: String representation of connected channels
///
/// ## JSON Serialization:
/// The class includes a factory constructor [fromJson] to create instances
/// from JSON data received from the API.
///
/// ## Example:
/// ```dart
/// final json = {
///   'IdChannel': '101',
///   'Position': 'FX_A1',
///   'Type': 'Fixture',
///   'State': 'connected',
///   'Connections': 'DMX_R1_1'
/// };
///
/// final channel = DMXChannel.fromJson(json);
/// print(channel.position); // Output: FX_A1
/// ```
///
/// ## Position Format:
/// - Fixture channels: "FX_{RowLetter}{ColumnNumber}" (e.g., "FX_A1", "FX_B12")
/// - DMX output channels: "DMX_R{RowNumber}_{ColumnNumber}" (e.g., "DMX_R1_1", "DMX_R2_12")
class DMXChannel {
  /// Unique identifier for the DMX channel.
  ///
  /// This ID is used to reference the channel in API calls and database operations.
  final int id;

  /// Physical or logical position identifier of the channel.
  ///
  /// For fixtures: Format is "FX_{RowLetter}{ColumnNumber}" (e.g., "FX_A1")
  /// For DMX outputs: Format is "DMX_R{RowNumber}_{ColumnNumber}" (e.g., "DMX_R1_1")
  final String position;

  /// Type of the DMX channel.
  ///
  /// Typically indicates whether this is a fixture channel or DMX output channel.
  /// Values are usually "Fixture" or "DMXOutput".
  final String type;

  /// Current connection state of the channel.
  ///
  /// Can be one of: "disconnected", "connected", or "broken".
  /// This field is mutable to allow updating the state during configuration.
  String state;

  /// String representation of connected channels.
  ///
  /// Format: "SourceChannel→TargetChannel" (e.g., "FX_A1→DMX_R1_1")
  /// Empty string indicates no connections.
  final String connections;

  /// Creates a DMXChannel instance with the specified properties.
  ///
  /// [id]: Unique identifier for the channel
  /// [position]: Position identifier string
  /// [type]: Channel type description
  /// [state]: Initial connection state
  /// [connections]: Connection information string
  DMXChannel(this.id, this.position, this.type, this.state, this.connections);

  /// Factory constructor to create a DMXChannel from JSON data.
  ///
  /// Parses the JSON response from the API and creates a properly formatted
  /// DMXChannel instance.
  ///
  /// ## JSON Structure:
  /// ```json
  /// {
  ///   "IdChannel": "101",
  ///   "Position": "FX_A1",
  ///   "Type": "Fixture",
  ///   "State": "connected",
  ///   "Connections": "DMX_R1_1"
  /// }
  /// ```
  ///
  /// [json]: Map containing the channel data from API response
  /// Returns a new [DMXChannel] instance with parsed data
  ///
  /// ## Throws:
  /// - [FormatException] if IdChannel cannot be parsed as integer
  factory DMXChannel.fromJson(Map<String, dynamic> json) {
    return DMXChannel(
      int.parse(json['IdChannel'].toString()),
      json['Position'].toString(),
      json['Type'].toString(),
      json['State'].toString(),
      json['Connections']?.toString() ?? '',
    );
  }
}
