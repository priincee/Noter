
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.4.0/firebase-app.js";
import { getFirestore, collection, getDocs, orderBy, query, updateDoc, doc, addDoc, deleteDoc, Timestamp }  from "https://www.gstatic.com/firebasejs/9.4.0/firebase-firestore.js";

let notes = []
let currentUser = ""
let selectedNote = {id:"", title:"", information:"", timestamp:"", docId:""}
const firebaseConfig = {
apiKey: "AIzaSyCJes03jPLsf5vx19cT22fvZx4y5YZLH0A",
authDomain: "stick-note-6283f.firebaseapp.com",
projectId: "stick-note-6283f",
storageBucket: "stick-note-6283f.appspot.com",
messagingSenderId: "780761022311",
appId: "1:780761022311:web:cb310b5e8c967b7b90b9c2"
};
initializeApp(firebaseConfig)

const db = getFirestore()


document.querySelectorAll('.note_editor').forEach((item, i) => {
  item.addEventListener('keyup', debounce( () => {updateSelectedNote()
}, 500))
})

window.addEventListener("DOMContentLoaded", () => {

  const addNewNoteButton = document.querySelector(".note_add")
  const deleteNoteButton = document.querySelector(".note_delete")
  addNewNoteButton.addEventListener("click", addNewNote)
  deleteNoteButton.addEventListener("click", deleteSelectedNote)
  getUser(getDataAndPopulatePage);

  });

async function getUser(callback) {
   await fetch("/getCurrentUserId",  {method: "GET", headers: {"Content-Type": "application/json"}}).then(res => res.json()).then(data=> currentUser = data.uid)
   callback()
}

function debounce(callback, wait) {
  let timeout;
  return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(function () { callback.apply(this, args); }, wait);
  };
}

function addNewNote() {
    const collectionRef = collection(db, "Users/"+currentUser+"/Notes")
  selectedNote = {id:"", title:"", information:"", timestamp:"", docId:""}
  addDoc(collectionRef, {id:uuidv4(), title:"", information:"", colour:["1", "1", "0"], timestamp: Timestamp.fromDate(new Date())}).then(() => clearContent())
}

function deleteSelectedNote() {
  let res = confirm(`Are you sure you want to delete: ${selectedNote.title}`)
  if (res){
    const docRef = doc(db, `Users/${currentUser}/Notes`, selectedNote.docId)
    selectedNote = {id:"", title:"", information:"", timestamp:"", docId:""}
    deleteDoc(docRef).then(() => clearContent())
  }
}

function updateSelectedNote() {
  const docRef = doc(db, `Users/${currentUser}/Notes`, selectedNote.docId)
  updateDoc(docRef, {title:document.querySelector(".note__title").value,
                     information:document.querySelector(".note__information").value,
                     timestamp: Timestamp.fromDate(new Date())
                   }).then(() => clearContent(document.querySelector('.note_noteList')))
}

function updateNoteColour(noteId, colour) {
  const docRef = doc(db, `Users/${currentUser}/Notes`, noteId)
  updateDoc(docRef, {colour: colour,  timestamp: Timestamp.fromDate(new Date())
  }).then(() => clearContent(document.querySelector('.note_noteList')))
}

function uuidv4() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
    (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16).toUpperCase()
  );}

function getDataAndPopulatePage() {
  const collectionRef = collection(db, "Users/"+currentUser+"/Notes")
  getDocs(query(collectionRef, orderBy("timestamp", "desc"))).then((snapShot) => {
  snapShot.docs.forEach((doc) => {
     notes.push({...doc.data(), docId: doc.id })
     console.log(doc)
   })
   populateNotes(notes)
  }).catch(err => {
   console.log(err.message)
  })
}
function populateNotes(array) {
  if (array.length <= 0 ) {
    document.querySelector(".note__title").style.display = "none"
    document.querySelector(".note__information").style.display = "none"
    document.querySelector(".note_delete").style.display = "none"
    document.querySelector(".note__lastModified").style.display = "none"
    document.querySelector(".no_notes").style.display = "block"
    return
  }
  else {
    document.querySelector(".note__title").style.display = "block"
    document.querySelector(".note__information").style.display = "block"
    document.querySelector(".note_delete").style.display = " inline-block"
    document.querySelector(".note__lastModified").style.display = "block"
    document.querySelector(".no_notes").style.display = "none"
  }
   array.forEach((note, i) => {
    const template = document.querySelector("#noteListing")
    const clonedNote = template.content.cloneNode(true)
    const noteListItem =   clonedNote.querySelector(".note_noteListItem")
    const noteList = document.querySelector('.note_noteList')
    noteListItem.dataset.id = note.id
    noteListItem.dataset.docId = note.docId
    noteListItem.dataset.timestamp = note.timestamp
    clonedNote.querySelector(".note_title").textContent = cutText(note.title, 25)
    clonedNote.querySelector(".note_information").textContent = cutText(note.information, 35)
    clonedNote.querySelector(".note_lastModified").textContent = moment((note.timestamp).toDate()).fromNow()
    clonedNote.querySelector(".color-picker-wrapper").style.backgroundColor = `rgb(${note.colour[0] * 255},${note.colour[1] * 255},${note.colour[2] * 255})`
    clonedNote.querySelector(".color-picker-wrapper").id = note.id
    clonedNote.querySelector(".color-picker-wrapper").querySelector(".color-picker").name = note.id
    clonedNote.querySelector(".color-picker-wrapper").querySelector(".color-picker").id = note.docId
    noteListItem.addEventListener("click", ()=> {selectNote(note.id)})
    noteList.appendChild(clonedNote)
  })
  document.querySelectorAll('.color-picker').forEach((item, i) => {
    item.onchange = function() {
       const id = `${this.name}`
	     document.getElementById(id.toString()).style.backgroundColor = this.value;
       updateNoteColour(this.id, hexTorgb(this.value))
    }
  })

   if (selectedNote.id !== "") {return} else {
     selectNote(notes[0].id)
   }
}

function hexTorgb(hex) {
  return [(('0x' + hex[1] + hex[2] | 0)/255).toString(),
  				(('0x' + hex[3] + hex[4] | 0)/255).toString(),
          (('0x' + hex[5] + hex[6] | 0)/255).toString()];
}

function selectNote(noteId) {
  if (document.querySelector("#selectedNote")){
    document.querySelector("#selectedNote").id = ""
  }
  notes.forEach((note, i) => {
    if (noteId === note.id) {
        selectedNote.id = note.id
        selectedNote.title = note.title
        selectedNote.information = note.information
        selectedNote.docId = note.docId
        document.querySelector(".note__title").value = note.title
        document.querySelector(".note__information").value = note.information
        document.querySelector(".note__lastModified").textContent = "Last modified on: " + timestampToDate(note.timestamp)
        document.querySelector(`.note_noteListItem[data-id="${note.id}"]`).id = "selectedNote"
    }
  })
}

function timestampToDate(timestamp) {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', minute: "numeric", hour: "numeric", second: "numeric"}
  return timestamp.toDate().toLocaleDateString(undefined, options)
}

function cutText(input, n) {
   return (input.length > n) ? input.substr(0, n-1) + '...' : input;
};

function clearContent(){
  document.querySelector('.note_noteList').textContent = ""
  notes = []
  getDataAndPopulatePage()
}
