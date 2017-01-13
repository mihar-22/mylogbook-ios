
import Foundation

struct Env {
#if DEBUG
    static let MLB_API_BASE = "http://mylogbook.dev/api/v1"
#else
    static let MLB_API_BASE = "https://mylogbook.com/api/v1"
#endif
}
