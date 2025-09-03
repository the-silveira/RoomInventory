/// Represents the possible connection states for DMX channels and fixtures.
///
/// This enum is used to track the current state of connections between
/// stage fixtures and DMX outputs in the lighting configuration system.
///
/// ## States:
/// - [disconnected]: The channel is not connected to any output
/// - [connected]: The channel is properly connected to a DMX output
/// - [broken]: The channel has a connection issue or hardware problem
///
/// ## Usage:
/// ```dart
/// final state = ConnectionState.connected;
/// if (state == ConnectionState.connected) {
///   // Handle connected state
/// }
/// ```
///
/// The connection states are used throughout the DMX configuration system
/// to visually represent and manage the connections between stage fixtures
/// and DMX output channels.
enum ConnectionState {
  /// The channel is not connected to any DMX output.
  ///
  /// This state indicates that the fixture is available for connection
  /// but currently not linked to any output channel.
  disconnected,

  /// The channel is properly connected to a DMX output.
  ///
  /// This state indicates an active and functional connection between
  /// a stage fixture and a DMX output channel.
  connected,

  /// The channel has a connection issue or hardware problem.
  ///
  /// This state indicates that there is a problem with the connection,
  /// such as a broken cable, faulty hardware, or configuration error.
  broken,
}
