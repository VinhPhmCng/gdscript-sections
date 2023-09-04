<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/VinhPhmCng/gdscript-sections">
	<img src="addons/godot_style/pictures/logo.png" alt="Logo">
  </a>

<h2 align="center">Godot Style</h3>

  <p align="center">
	A small Godot addon that provides unofficial style guide in the editor
	<br />
	<br />
	<br />
</p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
	<li><a href="#about-the-project">About The Project</a></li>
	<li><a href="#installation">Installation</a></li>
	<li><a href="#materials">Materials</a></li>
	<li><a href="#contribute">Contribute</a></li>
	<li><a href="#license">License</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

![Godot Style Screenshot 1](addons/godot_style/pictures/godot_style.gif)

### Built With

<p align="left"><a href="https://godotengine.org/"><img src="https://godotengine.org/assets/press/logo_large_color_dark.png" width=200></a></p>


### Version: Godot 4.1

- A personal project to learn the powerful Godot Engine
- Aiming at: 
  - Beginners who want to follow a prevalent style guide to develop good practices
  - Beginners who want to learn more about Godot's `Resource`


### More details
1. It makes use of `custom Resources`, which helps to quickly create new `SectionResources` and `ItemResources`.

2. It's very scuffed lol.
   - ~~Items can only contain pictures (Texture2D) as a quick and easy alternative - because I haven't a clue how to implement **markdown** in Godot. As a result,~~
	 - ~~Updating contents frequently can be cumbersome.~~
	 - ~~Limited capabilities~~
	 - ~~Resizing the editor will not scale the pictures to maintain visibility -> Have to use scroll bars~~  
	
   - Scuffed **Markdown** implementation (Converting to BBCode for `RichTextLabel` and custom `Controls` - using [RegEx](https://docs.godotengine.org/en/stable/classes/class_regex.html))
	 - [x] Most basic and widely used syntax
	 - [ ] Lists (ordered and unordered) - prove difficult because lists in Markdown and BBCode are quite different
	 - [ ] HTML tags - none yet  

   - Lacking UI elements helping to add new contents - partly because I want users to interact with the provided custom resources

3. The style guide provided ([STYLE_GUIDE.md](STYLE_GUIDE.md)) is a simplified composition of parts of different [materials](#materials).

4. There are two script templates located in [script_templates](script_templates). To integrate them into your project or editor, please refer to [Creating script templates](https://docs.godotengine.org/en/stable/tutorials/scripting/creating_script_templates.html).


### Customization
- You can add your own `SectionResources` and `ItemResources` - please refer to [ADDING_YOUR_OWN.md](ADDING_YOUR_OWN.md)


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- INSTALLATION -->
## Installation

### Using Godot Asset Library
- In-editor `AssetLib`
  1. Search for `Godot Style` in Godot's in-editor `AssetLib` and press download 

  2. Enable the addon in `Project -> Project Settings -> Plugins`

		![Enabling-addon](addons/godot_style/pictures/enable_addon.PNG)

- Online
  1. Dowload the ZIP archive from [link](https://godotengine.org/asset-library/asset/2038).

  2. Import the folder `godot_style/` into your Godot project's `addons/` folder (Godot v4.1).

  3. Enable the addon in `Project -> Project Settings -> Plugins`

### Manually
1. Clone the repo OR download and extract the ZIP archive.
   ```sh
   git clone https://github.com/VinhPhmCng/GodotStylePlugin.git
   ```

2. Import the folder `godot_style/` into your Godot project's `addons/` folder (Godot v4.1).

3. Enable the addon in `Project -> Project Settings -> Plugins`

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MATERIALS -->
## Materials

1. [GDScript style guide](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_styleguide.html)
2. [GDScript reference](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_basics.html#doc-gdscript)
3. [GDQuest' guidelines](https://gdquest.gitbook.io/gdquests-guidelines/godot-gdscript-guidelines)
4. [Calinou's style guide](https://github.com/Calinou/godot-style-guide)
5. [emarino135's Reddit thread](https://www.reddit.com/r/godot/comments/yngda3/gdstyle_naming_convention_and_code_order_cheat/)
6. [sepTN's post](https://godot.community/topic/27/gdscript-coding-conventions-best-practices-for-readable-and-maintainable-code)


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTRIBUTE -->
## Contribute

- Any contribution is much appreciated, especially regarding **Markdown** integration into Godot.

- I highly recommend beginners who is learning programming in general, or Godot specifically, to make contributions if you'd like to.
  - For example, you can add more style guide items that you think would help other beginners.
  - Open PR to improve the addon.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License
[MIT License](LICENSE) © [VPC](https://github.com/VinhPhmCng)


<p align="right">(<a href="#readme-top">back to top</a>)</p>