function optionsSlider(key, default, min, max)
	UiPush();
		local value = (GetInt(key) - min) / (max - min);
		local width = 100;
		UiRect(width, 3);
		UiAlign("center middle");
		value = UiSlider("ui/common/dot.png", "x", value * width, 0, width) / width;
		value = math.floor(value * (max - min) + min);
		SetInt(key, value);
	UiPop();
	return value;
end

function draw()
	UiTranslate(UiCenter(), 250)
	UiAlign("center middle")

	--Title
	UiFont("bold.ttf", 48)
	UiText("Options")
	
	--Sliders
	UiPush();
		UiTranslate(-150, 100);
		UiText("Damage threshold");
		UiAlign("left");
		UiTranslate(200, 0);
		local v1 = optionsSlider("savegame.mod.threshold", 50, 40, 70);
		UiTranslate(150, 10);
		UiText(v1);
	UiPop();
	
	UiPush();
		UiTranslate(-150, 200);
		UiText("Samples per shape");
		UiAlign("left");
		UiTranslate(200, 0);
		local v2 = optionsSlider("savegame.mod.samples", 2000, 500, 7500);
		UiTranslate(150, 10);
		UiText(v2);
	UiPop();

	UiPush();
		UiTranslate(-150, 300);
		UiText("Iterations per frame");
		UiAlign("left");
		UiTranslate(200, 0);
		local v2 = optionsSlider("savegame.mod.iterations", 5, 1, 25);
		UiTranslate(150, 10);
		UiText(v2);
	UiPop();

	UiPush();
		UiTranslate(-150, 400);
		UiText("Min shape size");
		UiAlign("left");
		UiTranslate(200, 0);
		local v3 = optionsSlider("savegame.mod.minshape", 1000, 500, 5000);
		UiTranslate(150, 10);
		UiText(v3);
	UiPop();
	
	UiTranslate(0, 600)
	if UiTextButton("Reset to default", 200, 40) then
		SetInt("savegame.mod.threshold", 50)
		SetInt("savegame.mod.samples", 2000)
		SetInt("savegame.mod.iterations", 5)
		SetInt("savegame.mod.minshape", 1000)
	end
	
	UiTranslate(0, 50)
	if UiTextButton("Close", 200, 40) then
		Menu()
	end
end
