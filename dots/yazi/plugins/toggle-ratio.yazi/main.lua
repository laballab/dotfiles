--- @sync entry

local original_layout = Tab.layout

local function entry(st)
	local R = rt.mgr.ratio
	if st.expanded
		then st.parent, st.current, st.preview = R.parent, R.current, R.preview
		else st.parent, st.current, st.preview = 1, 2, 5
	end
	st.expanded = not st.expanded
	Tab.layout = function(self) -- override layout
		original_layout(self) -- preserve height
		local all = st.parent + st.current + st.preview
		self._chunks = ui.Layout() -- update layout
			:direction(ui.Layout.HORIZONTAL)
			:constraints({ -- override ratio split
				ui.Constraint.Ratio(st.parent, all),
				ui.Constraint.Ratio(st.current, all),
				ui.Constraint.Ratio(st.preview, all),
			})
			:split(self._area)
	end
	ya.emit("app:resize", {})
end
return { entry = entry }
