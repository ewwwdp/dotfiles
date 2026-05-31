-- workspaces per monitor
-- 1..5
for i = 1, 5 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
end
-- 6..10
for i = 6, 10 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end
