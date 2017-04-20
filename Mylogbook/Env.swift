
import Foundation

struct Env {
#if DEBUG
    static let MLB_API_BASE = "http://mylogbook.dev/api/v1"
#else
    static let MLB_API_BASE = "https://mylb.com.au/api/v1"
#endif
}
