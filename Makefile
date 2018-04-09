all: swadge_case_plunger.stl swadge_case_base.stl swadge_case_top.stl

swadge_case_plunger.stl: swadge_case.scad
	openscad -o $@ -D'mode="plunger"' $^

swadge_case_base.stl: swadge_case.scad
	openscad -o $@ -D'mode="bottom"' $^

swadge_case_top.stl: swadge_case.scad
	openscad -o $@ -D'mode="top"' $^
