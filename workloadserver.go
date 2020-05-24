package main

import (
	"bufio"
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

//Map that keeps track of which students are in the specific class
var c map[string][]string

//struct model for an event recieved from the client
type Eventmodel struct {
	Name  string `json:"Name"`
	Date  string `json:"Date"`
	Class string `json:"Class"`
}

func newEvent(s []Eventmodel, e string) bool {
	//checks if an array already has an event
	for _, a := range s {
		if a.Name == e {
			return false
		}
	}
	return true
}

//Map that keeps track of all events a specific student has
var e map[string][]Eventmodel

func handlerClass(w http.ResponseWriter, r *http.Request) {
	// Let's print the info
	fmt.Println("Incoming Request: ")
	fmt.Println("Method: ", r.Method, " ", r.URL)

	className := strings.Split(r.URL.Path, "/")[2]

	className, _ = url.PathUnescape(className)

	println(className)

	var publishedEvents = []Eventmodel{}

	// Take className and use the c map to collect all relevent students
	// Add all the events from each student from the e map into one form
	for _, a := range c[className] {
		println(1)
		println(a)
		for _, b := range e[a] {
			println(2)
			println(b.Class)
			//sort out events that aren't within two weeks
			var twoWeek = time.Now().Add(time.Hour * 24 * 14)
			const longForm = "Mon Jan 2 15:04:05 -0700 MST 2006"
			eventTime, _ := time.Parse(longForm, b.Date)
			if eventTime.After(time.Now()) && eventTime.Before(twoWeek) {
				println(3)
				//only run this if publishedEvents has items already
				if len(publishedEvents) > 0 {
					//make sure the current event isn't already there
					if newEvent(publishedEvents, b.Name) {
						println(4)
						//run loop to insert event chronologically
						for index, c := range publishedEvents {
							println(5)
							cTime, _ := time.Parse(longForm, c.Date)
							if eventTime.Before(cTime) {
								println(6)
								publishedEvents = append(publishedEvents, Eventmodel{"", "", ""})
								copy(publishedEvents[index+1:], publishedEvents[index:])
								publishedEvents[index] = b
								break
							} else if index+1 == len(publishedEvents) {
								println(6)
								publishedEvents = append(publishedEvents, b)
								break
							}
						}
					}
				} else {
					print("first event")
					publishedEvents = append(publishedEvents, b)
				}

			}

		}
	}

	var names = []string{}
	var dates = []string{}
	var classes = []string{}
	println(7)
	for _, a := range publishedEvents {
		println(8)
		names = append(names, a.Name)
		dates = append(dates, a.Date)
		classes = append(classes, a.Class)
	}

	println(names[0])
	println(dates[0])
	println(classes[0])

	println(8)

	namesJSON, _ := json.Marshal(names)
	datesJSON, _ := json.Marshal(dates)
	classesJSON, _ := json.Marshal(classes)

	finalJSON := "{\"Names\": " + string(namesJSON) + ", \"Dates\": " + string(datesJSON) + ", \"Classes\": " + string(classesJSON) + "}"

	fmt.Fprintf(w, finalJSON)

}

func handlerNewEvent(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Incoming Request: ")
	fmt.Println("Method: ", r.Method, " ", r.URL)

	//Collect event data from the client here...
	//Code originally from Spencer Michaels
	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
	newStr := buf.String()
	fmt.Println(newStr)
	var data Eventmodel

	//Create struct for the event
	//Code originally from Spencer Michaels
	json.Unmarshal([]byte(newStr), &data)

	fmt.Println(data.Name)
	fmt.Println(data.Date)
	fmt.Println(data.Class)

	//Use the c map to add the event to the e map of all relevant students
	for _, a := range c[data.Class] {
		e[a] = append(e[a], data)
		println("%v", e[a])
	}

	println("200 - ok")

}

func main() {
	c = make(map[string][]string)
	e = make(map[string][]Eventmodel)
	csvFile, _ := os.Open("Classes.csv")
	reader := csv.NewReader(bufio.NewReader(csvFile))

	for {
		line, error := reader.Read()
		if error == io.EOF {
			break
		} else if error != nil {
			log.Fatal(error)
		}
		for i := 1; ; i++ {
			if line[i] == "" {
				break
			}
			c[line[0]] = append(c[line[0]], line[i])
			println("finished indexing...")
		}

	}

	http.HandleFunc("/Class/", handlerClass)
	http.HandleFunc("/Event", handlerNewEvent)
	log.Fatal(http.ListenAndServe(":80", nil))
}
