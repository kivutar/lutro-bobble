SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

ENTITIES = {}
SOLIDS = {}
EFFECTS = {}
SHADOWS = {}
MAP = {}
PHASE = nil
STAGE = 1
CHAR1 = nil
CHAR2 = nil
BGM = nil
LAST_UID = 0

SHOW_DEBUG_INFO = false				-- Prints debug information on screen when enabled.
GRAPH_UNIT_SCALE = 5                -- The height scaled use for drawing stat graphs

-- Network Settings
SERVER_IP = "127.0.0.1"	            -- The network address of the other player to connect to.

SERVER_PORT = 5552					-- The network port the server is running on.
NET_INPUT_DELAY	= 3					-- Amount of input delay to use by default during online matches. Should always be > 0
NET_ROLLBACK_MAX_FRAMES	= 10		-- The maximum number of frames we allow the game run forward without a confirmed frame from the opponent.
NET_DETECT_DESYNCS = true			-- Whether or not desyncs are detected and terminates a network session.

NET_INPUT_HISTORY_SIZE = 60			-- The size of the input history buffer. Must be atleast 1.
NET_SEND_HISTORY_SIZE = 5			-- The number of inputs we send from the input history buffer. Must be atleast 1.
NET_SEND_DELAY_FRAMES = 0			-- Delay sending packets when this value is great than 0. Set on both clients to not have one ended latency.

-- Rollback test settings
ROLLBACK_TEST_ENABLED   = false
ROLLBACK_TEST_FRAMES    = 10		-- Number of frames to rollback for tests.

