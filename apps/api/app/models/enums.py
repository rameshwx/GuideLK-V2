import enum


class TripStatus(str, enum.Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    ARCHIVED = "archived"


class TripStopKind(str, enum.Enum):
    POI = "poi"
    STAY = "stay"


class TripStopStatus(str, enum.Enum):
    PLANNED = "planned"
    VISITED = "visited"
    SKIPPED = "skipped"


class BookingSource(str, enum.Enum):
    MANUAL = "manual"
    BOOKING_IMPORT = "booking_import"
