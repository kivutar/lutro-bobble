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
RDV_IP = "195.201.56.250"
RDV_PORT = 1234

NET_INPUT_DELAY	= 3					-- Amount of input delay to use by default during online matches. Should always be > 0
NET_ROLLBACK_MAX_FRAMES	= 10		-- The maximum number of frames we allow the game run forward without a confirmed frame from the opponent.
NET_DETECT_DESYNCS = true			-- Whether or not desyncs are detected and terminates a network session.

NET_INPUT_HISTORY_SIZE = 60			-- The size of the input history buffer. Must be atleast 1.
NET_SEND_HISTORY_SIZE = 5			-- The number of inputs we send from the input history buffer. Must be atleast 1.
NET_SEND_DELAY_FRAMES = 0			-- Delay sending packets when this value is great than 0. Set on both clients to not have one ended latency.

-- Rollback test settings
ROLLBACK_TEST_ENABLED   = false
ROLLBACK_TEST_FRAMES    = 10		-- Number of frames to rollback for tests.

RETRO_DEVICE_ID_JOYPAD_B        = 1
RETRO_DEVICE_ID_JOYPAD_Y        = 2
RETRO_DEVICE_ID_JOYPAD_SELECT   = 3
RETRO_DEVICE_ID_JOYPAD_START    = 4
RETRO_DEVICE_ID_JOYPAD_UP       = 5
RETRO_DEVICE_ID_JOYPAD_DOWN     = 6
RETRO_DEVICE_ID_JOYPAD_LEFT     = 7
RETRO_DEVICE_ID_JOYPAD_RIGHT    = 8
RETRO_DEVICE_ID_JOYPAD_A        = 9
RETRO_DEVICE_ID_JOYPAD_X        = 10
RETRO_DEVICE_ID_JOYPAD_L        = 11
RETRO_DEVICE_ID_JOYPAD_R        = 12
RETRO_DEVICE_ID_JOYPAD_L2       = 13
RETRO_DEVICE_ID_JOYPAD_R2       = 14
RETRO_DEVICE_ID_JOYPAD_L3       = 15
RETRO_DEVICE_ID_JOYPAD_R3       = 16
