enum mouse_button {
  MouseButtonLeft = 1,
  MouseButtonRight = 2,
}

enum mouse_event {
  MouseDown = 1,
  MouseUp = 2,
  MouseDragged = 3,
  MouseMoved = 4,
}

enum key_event {
  KeyDown = 1,
  KeyUp = 2,
}

service mac_agent {
	i32 handle_mouse_cmd(1: string window_name, 2: mouse_button button, 3: mouse_event event, 4: i32 x, 5: i32 y),
	i32 handle_key_cmd(1: string window_name, 2: string key, 3: key_event event),
	i32 handle_screenshot_cmd(1: string window_name, 2: string screenshot_path)
}
