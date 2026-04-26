package main

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

main :: proc() {
	image_gpu: rl.Texture2D
	image_raw, err := os.read_entire_file_from_file(os.stdin, context.allocator)
	if err != nil {
		fmt.println("failed to load")
	}
	fmt.println("DONE")
	image_cpu := rl.LoadImageFromMemory(".png", raw_data(image_raw), i32(len(image_raw)))
	fmt.println("CPU DONE")
	if rl.IsImageReady(image_cpu) {
		fmt.println("Ready")
	}

	screen_width: i32 = image_cpu.width
	screen_height: i32 = image_cpu.height

	rl.SetTraceLogLevel(rl.TraceLogLevel.NONE)
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.InitWindow(screen_width, screen_height, "sannity")
	rl.SetWindowMinSize(screen_width, screen_height)
	rl.SetTargetFPS(60)

	image_gpu = rl.LoadTextureFromImage(image_cpu)
	fmt.println("GPU DONE")


	for !rl.WindowShouldClose() && (err == nil) {

		// Save to disk
		if rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) && rl.IsKeyPressed(rl.KeyboardKey.S) {
			output := rl.LoadImageFromScreen()
			size: i32 = output.height * output.width
			ray_output := rl.ExportImageToMemory(output, ".png", &size)
			raw_output := ([^]u8)(ray_output)[:size]
			err := os.write_entire_file_from_bytes("ScreenshotRecent.png", raw_output)
			if err != nil {
				fmt.println("error")
			}
			break
		}

		// Save to clipboard
		if rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) && rl.IsKeyPressed(rl.KeyboardKey.C) {
			output := rl.LoadImageFromScreen()
			size: i32 = output.height * output.width
			ray_output := rl.ExportImageToMemory(output, ".png", &size)
			raw_output := ([^]u8)(ray_output)[:size]

			fmt.println("Creating pipe")
			r, w, e := os.pipe()
			fmt.println("Done")

			fmt.println("Creating Process Desc")
			desc: os.Process_Desc = {
				working_dir = "/usr/bin",
				command     = {"wl-copy", "-f"},
				stdin       = r,
			}
			fmt.println("Done")

			fmt.println("Creating wl-copy process")
			wl_copy, error := os.process_start(desc)
			fmt.println("Done")
			fmt.println(wl_copy)

			fmt.println("Writing to pipe")
			os.write(w, raw_output)
			fmt.println("Done")
			fmt.println("Closing Pipe")
			os.close(w)
			fmt.println("Done")

			fmt.println("Ending wl-copy Process")
			state, wait_err := os.process_wait(wl_copy, 0)
			fmt.println("Done")
			fmt.println(state)
		}

		if rl.IsKeyDown(rl.KeyboardKey.LEFT_CONTROL) && rl.IsKeyPressed(rl.KeyboardKey.Z) {
		if Line_Index > 0 {
			Line_Index -= 1
			pop(&Line)
		}
			
		}

		if rl.IsKeyDown(rl.KeyboardKey.ONE) {
			CurrentColor = rl.RED
		}
		if rl.IsKeyDown(rl.KeyboardKey.TWO) {
			CurrentColor = rl.GREEN
		}
		if rl.IsKeyDown(rl.KeyboardKey.THREE) {
			CurrentColor = rl.BLUE
		}

		create_line()

		rl.BeginDrawing()
		rl.ClearBackground({40, 40, 40, 255})
		rl.DrawTexture(image_gpu, 0, 0, rl.WHITE)
		// Line to Draw
		for l := 0; l < len(Line); l += 1 {
			rl.DrawSplineCatmullRom(
				raw_data(Line[l].Points[:]),
				Line[l].CurveLength,
				4,
				Line[l].ColorOrder,
			)
		}
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

Curves :: struct {
	CurveLength: i32,
	Points:      [dynamic]rl.Vector2,
	ColorOrder:  rl.Color,
}
CurrentColor: rl.Color = rl.RED
Line: [dynamic]Curves
Line_Index: int = 0
DOWNSTROKE: bool = false

create_line :: proc() {
	if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
		if !DOWNSTROKE {
			DOWNSTROKE = true
			temp: Curves
			append(&Line, temp)
			Line[Line_Index].ColorOrder = CurrentColor
			append(&Line[Line_Index].Points, rl.GetMousePosition())
			append(&Line[Line_Index].Points, rl.GetMousePosition())
		} else if DOWNSTROKE {
			append(&Line[Line_Index].Points, rl.GetMousePosition())
			Line[Line_Index].CurveLength = i32(len(Line[Line_Index].Points))
		}
	} else if rl.IsMouseButtonReleased(rl.MouseButton.LEFT) {
		DOWNSTROKE = false
		append(&Line[Line_Index].Points, rl.GetMousePosition())
		append(&Line[Line_Index].Points, rl.GetMousePosition())
		fmt.println(Line[Line_Index].Points)
		Line[Line_Index].CurveLength = i32(len(Line[Line_Index].Points))
		Line_Index += 1

	}

}
