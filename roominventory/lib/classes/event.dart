/// Represents an event with its details and contact information.
///
/// The Event class encapsulates all the information related to an event
/// in the room inventory system, including identification, location,
/// responsible personnel, and technical details.
///
/// ## Properties:
/// - [IdEvent]: Unique identifier for the event
/// - [EventName]: Name or title of the event
/// - [EventPlace]: Physical location where the event takes place
/// - [NameRep]: Name of the event representative/responsible person
/// - [EmailRep]: Email address of the event representative
/// - [TecExt]: Technical details or external technical requirements
/// - [Date]: Date when the event occurs (format: YYYY-MM-DD)
///
/// ## Usage:
/// This class is primarily used for:
/// - Displaying event information in lists and details pages
/// - API communication for event management operations
/// - Data persistence and retrieval from the database
///
/// ## Example:
/// ```dart
/// final event = Event(
///   'EVT-2023-001',
///   'Annual Conference',
///   'Main Auditorium',
///   'John Doe',
///   'john.doe@example.com',
///   'Projector, Microphones, Lighting',
///   '2023-12-15'
/// );
///
/// print(event.EventName); // Output: Annual Conference
/// ```
///
/// ## Data Format:
/// - All fields are stored as strings for flexibility
/// - [Date] should follow ISO 8601 format (YYYY-MM-DD) for consistency
/// - [IdEvent] typically follows a specific pattern (e.g., "EVT-{year}-{sequence}")
class Event {
  /// Unique identifier for the event.
  ///
  /// This ID is used to uniquely identify the event across the system.
  /// Typically follows a specific pattern like "EVT-2023-001" or similar.
  /// Used for API calls, database operations, and event referencing.
  final String IdEvent;

  /// Name or title of the event.
  ///
  /// Descriptive name that identifies the event to users.
  /// Examples: "Annual Conference", "Product Launch", "Training Workshop"
  final String EventName;

  /// Physical location where the event takes place.
  ///
  /// Specifies the room, hall, or venue where the event is scheduled.
  /// Examples: "Main Auditorium", "Room 101", "Conference Hall B"
  final String EventPlace;

  /// Name of the event representative or responsible person.
  ///
  /// The primary contact person responsible for the event.
  /// Used for communication and accountability purposes.
  final String NameRep;

  /// Email address of the event representative.
  ///
  /// Contact email for the responsible person.
  /// Used for notifications, confirmations, and communication.
  final String EmailRep;

  /// Technical details or external technical requirements.
  ///
  /// Describes any special technical equipment, setups, or requirements
  /// needed for the event. Examples: "Projector, Sound System, WiFi"
  /// or "DMX Lighting, Stage Setup, Video Recording"
  final String TecExt;

  /// Date when the event occurs.
  ///
  /// Should be formatted as YYYY-MM-DD (ISO 8601 format).
  /// Used for scheduling, filtering, and calendar operations.
  final String Date;

  /// Creates an Event instance with all required details.
  ///
  /// [IdEvent]: Unique identifier for the event
  /// [EventName]: Descriptive name of the event
  /// [EventPlace]: Location where the event takes place
  /// [NameRep]: Name of the responsible person
  /// [EmailRep]: Email address of the responsible person
  /// [TecExt]: Technical requirements and details
  /// [Date]: Event date in YYYY-MM-DD format
  Event(this.IdEvent, this.EventName, this.EventPlace, this.NameRep,
      this.EmailRep, this.TecExt, this.Date);
}
