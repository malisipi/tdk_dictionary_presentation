[translated]
module main

import malisipi.mui
import net.http
import rand
import json
import time
import gg

const (
	max_id_count = 92411
)

struct TDK_Response_List {
	anlam_sira	int
	fiil		int
	anlam		string
}

struct TDK_Response {
	madde	string
	anlamlarListe []TDK_Response_List
}

fn tdk_get_word()! TDK_Response {
	word_id := rand.intn(max_id_count)!
	request := http.get("https://sozluk.gov.tr/gts_id?id=${word_id}")!
	json_info := json.decode([]TDK_Response, request.body)!
	return json_info[0]
}

fn display_loop(mut app &mui.Window){
	for ;; {
		the_word := tdk_get_word() or {
			TDK_Response {
				madde: "#404"
				anlamlarListe: [
					TDK_Response_List {
						anlam: "Fetch failed"
					}
				]
			}
		}
		$if DEBUG_MODE? {
			println(the_word)
		}
		app.get_object_by_id("word")[0]["text"].str = the_word.madde.capitalize()
		mut description_text := ""
		for which_meaning, meaning in the_word.anlamlarListe {
			description_text += "${which_meaning+1}. ${meaning.anlam.capitalize()}\n"
		}
		app.get_object_by_id("description")[0]["text"].str = description_text

		$if !DEBUG_MODE? {
			time.sleep(time.second * 20)
		} $else {
			time.sleep(time.second * 4)
		}

	}
}

fn main(){
	app := mui.create(title:"TDK Dictionary Presentation from malisipi" init_fn: fn (event_details mui.EventDetails, mut app mui.Window, mut _ voidptr){
		gg.toggle_fullscreen()
		go display_loop(mut app)
	})
	app.label(id: "word" x: 50 y: 50 height: 200 width: "100%x -100" text_size: 128 text_align: 0)
	app.label(id: "description" x: 80 y: 275 height: "100%y -325" width: "100%x -160" text_size: 64, text_align: 0, text_multiline: true)
	app.link(id: "source" text: "Source Code @ malisipi" x: 25 y: "# 25" height: 25 width: 250 link:"https://github.com/malisipi/tdk_dictionary_presentation")
	app.button(id: "close" text:"✖️" icon:true x: "# 25" y: "# 25" height: 25 width: 25 onclick: fn(event_details mui.EventDetails, mut app mui.Window, mut _ voidptr){ app.destroy() })
	app.run()
}