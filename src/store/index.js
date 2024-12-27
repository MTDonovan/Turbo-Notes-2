import { reactive, toRaw } from 'vue'
import { LocalStorage } from 'quasar'

const initialState = reactive({
  state: {
    checklists: [],
  },
})

/**
 * Instantiate global state object.
 */
export let state = reactive(JSON.parse(JSON.stringify(toRaw(initialState))))

/**
 * Reset the state object (for debugging purposes).
 */
export function resetState() {
  /**
   * Overwrite the state object to it's initial state.
   */
  state = reactive(JSON.parse(JSON.stringify(toRaw(initialState))))
}

export const getters = {
  getAllCheckLists(state) {
    return state.checklists
  },
  getActiveChecklist(state) {
    if (!state.checklists) {
      return {}
    }
    if (state.checklists.length < 1) {
      return {}
    }
    return state.checklists.filter((i) => i.active)[0]
  },
}

export const mutations = {
  /**
   * Add a new object to the active checklist's items array.
   * @param state
   * @param itemObj
   */
  addNewChecklistItem(state, itemObj) {
    state.checklists.map((i) => {
      if (i.active) {
        i.items.push(itemObj)
      }
    })

    LocalStorage.set('checklists', state.checklists)
  },
  /**
   * When a checklist item is selected, remove all selected items
   * from the active checklist.
   * @param state
   * @param selectedChecklistItems
   */
  removeSelectedChecklistItems(state, selectedChecklistItems) {
    /** In the event no checklist items are selected, exit the mutation. */
    if (!selectedChecklistItems) {
      return
    }

    /** Return the active checklist items that are currently selected. */
    let filterChecklistItems = (checklistItems, selectedItems) => {
      let filteredItems = []
      for (let x = 0; x < checklistItems.length; x++) {
        if (!selectedItems.includes(checklistItems[x])) {
          filteredItems.push(checklistItems[x])
        }
      }
      return filteredItems
    }

    for (let x = 0; x < state.checklists.length; x++) {
      if (state.checklists[x].active) {
        state.checklists[x].items = filterChecklistItems(
          state.checklists[x].items,
          selectedChecklistItems,
        )
      }
    }

    LocalStorage.set('checklists', state.checklists)
  },
  initLocalStorage(state) {
    state.checklists = LocalStorage.getItem('checklists')
  },
  addNewChecklist(state, checklistObj) {
    if (!state.checklists) {
      state.checklists = []
    }
    state.checklists.push(checklistObj)
    if (state.checklists.length === 1) {
      state.checklists[0].active = true
    }
    LocalStorage.set('checklists', state.checklists)
  },
  removeSelectedChecklists(state) {
    let nonSelectedChecklistsArray = state.checklists.filter((i) => !i.selected)
    if (nonSelectedChecklistsArray.filter((i) => i.active).length < 1) {
      state.checklists = nonSelectedChecklistsArray
      if (!state.checklists.length < 1) {
        state.checklists[state.checklists.length - 1].active = true
      }
    }
    state.checklists = nonSelectedChecklistsArray
    LocalStorage.set('checklists', state.checklists)
  },
  setActiveCheckList(state, selectedChecklistId) {
    let result = state.checklists.filter((i) => {
      if (i.active && i.id === selectedChecklistId) {
        return ''
      } else if (!i.active && i.id === selectedChecklistId) {
        return i
      }
    })
    if (result[0]) {
      state.checklists.map((i) => {
        if (i.id === selectedChecklistId) {
          i.active = true
        } else {
          i.active = false
        }
      })
    }
    LocalStorage.set('checklists', state.checklists)
  },
  updateChecklist(state, checklistObj) {
    state.checklists.map((i) => {
      if (i.id === checklistObj.id) {
        i.name = checklistObj.name
        i.desc = checklistObj.desc
      }
    })
    LocalStorage.set('checklists', state.checklists)
  },
  setChecklists(state, updatedChecklistsArray) {
    state.checklists = updatedChecklistsArray
    LocalStorage.set('checklists', state.checklists)
  },
  updateChecklistItem(state, itemObj) {
    let activeChecklist = state.checklists.filter((i) => i.active)[0]
    state.checklists.map((i) => {
      if (i.id === activeChecklist.id) {
        i.items.map((i) => {
          if (i.id === itemObj.id) {
            i.text = itemObj.text
          }
        })
      }
    })
    LocalStorage.set('checklists', state.checklists)
  },
  setChecklistItems(state, updatedItemsArray) {
    let activeChecklist = state.checklists.filter((i) => i.active)[0]
    state.checklists.map((i) => {
      if (i.id === activeChecklist.id) {
        i.items = updatedItemsArray
      }
    })
    LocalStorage.set('checklists', state.checklists)
  },
}
