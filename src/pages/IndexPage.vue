<!-- <template>
  <q-page class="flex flex-center">
    <img
      alt="Quasar logo"
      src="~assets/quasar-logo-vertical.svg"
      style="width: 200px; height: 200px"
    />
  </q-page>
</template>

<script>
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'IndexPage',
})
</script> -->

<template>
  <q-page name="internal checklist view" id="main-notes-index" class="flex flex-left">
    <q-list class="checklist-entities-format">
      <div class="checklist-button-group">
        <q-btn
          name="add new checklist item"
          @click="prompt = true"
          square
          :disable="disableChecklistItemButtons"
          class="col-6"
          color="primary"
          icon="note_add"
        />
        <q-btn
          name="remove checklist item"
          @click="_removeSelectedChecklistItems()"
          square
          :disable="disableChecklistItemButtons"
          class="col-6"
          color="secondary"
          icon="remove_circle"
        />
      </div>

      <q-item-label v-if="!activeChecklist.id" class="no-active-checklist-found-message"
        >No checklist is currently open.<br /><br />Click the hamburger icon at the top left to open
        the checklists overview.</q-item-label
      >
      <draggable
        v-if="activeChecklist"
        v-model="activeChecklistItems"
        @start="drag = true"
        @end="drag = false"
        handle=".handle"
        item-key="id"
      >
        <template #item="{ element }">
          <q-item class="checklist-item" :key="element.id">
            <q-item-section class="col-1" style="margin-right: 12px">
              <q-checkbox v-model="element.selected"></q-checkbox>
            </q-item-section>
            <q-item-section class="col-8">
              <q-item-label v-if="element.text" @click="openUpdateChecklistItemPrompt(element)">{{
                element.text
              }}</q-item-label>
              <q-item-label v-else @click="openUpdateChecklistItemPrompt(element)"
                ><i>No item text</i></q-item-label
              >
            </q-item-section>
            <q-item-section class="col-2">
              <q-btn flat icon="menu" class="handle"></q-btn>
            </q-item-section>
          </q-item>
        </template>
      </draggable>
    </q-list>

    <q-dialog v-model="prompt" persistent>
      <q-card style="min-width: 350px">
        <!-- <q-card-section>
            <div class="text-h6">New checklist item</div>
          </q-card-section> -->
        <q-card-section>
          <q-input
            name="new checklist item name input"
            placeholder="Enter checklist item text"
            dense
            v-model="tempItemText"
            autofocus
            @keyup.enter="_addNewChecklistItem()"
          />
        </q-card-section>
        <q-card-actions align="left" class="text-primary">
          <q-btn @click="_addNewChecklistItem()" flat label="Add" v-close-popup />
          <q-btn flat label="Cancel" v-close-popup @click="closePrompt()" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="updateItemPrompt" persistent>
      <q-card style="min-width: 350px">
        <q-card-section>
          <q-input
            placeholder="Update checklist item text"
            dense
            v-model="tempItemText"
            autofocus
            @keyup.enter="_updateChecklistItem()"
          />
        </q-card-section>
        <q-card-actions align="left" class="text-primary">
          <q-btn @click="_updateChecklistItem()" flat label="Update" v-close-popup />
          <q-btn flat label="Cancel" v-close-popup @click="closePrompt()" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { state, getters, mutations } from 'src/store/index'
import { v4 as uuidv4 } from 'uuid'
import draggable from 'vuedraggable'

export default {
  name: 'IndexPage',
  components: {
    draggable,
  },
  data() {
    return {
      prompt: false,
      tempItemText: '',
      updateItemPrompt: false,
      updateChecklistItemObj: {},
    }
  },
  computed: {
    activeChecklist() {
      return getters.getActiveChecklist(state)
    },
    activeChecklistItems: {
      get() {
        return getters.getActiveChecklist(state).items
      },
      set(updatedItemsArray) {
        mutations.setChecklistItems(state, updatedItemsArray)
      },
    },
    disableChecklistItemButtons() {
      if (!state.checklists) {
        return false
      }
      return state.checklists.length >= 1 ? false : true
    },
  },
  mounted() {
    console.log(
      `[index page] Mounted with active checklist "${getters.getActiveChecklist(state).name}"`,
    )
    this.updatePageDimensions()
    this.$nextTick(() => {
      window.addEventListener('resize', () => {
        this.updatePageDimensions()
      })
    })
  },
  watch: {
    activeChecklist() {
      this.updatePageDimensions()
    },
  },
  methods: {
    waitForDocumentElement(selector) {
      return new Promise((resolve) => {
        let waitForElementToDisplay = (selector, time) => {
          if (document.querySelector(selector) != null) {
            resolve(document.querySelector(selector))
          } else {
            setTimeout(() => {
              waitForElementToDisplay(selector, time)
            }, time)
          }
        }
        waitForElementToDisplay(selector, 100)
      })
    },
    updatePageDimensions() {
      this.waitForDocumentElement('.checklist-item').then((element) => {
        element.setAttribute('style', `width: ${(window.innerWidth * (80 / 100)).toString()}px;`)
        console.log('[index page] Updated checklist page dimensions')
      })
    },
    filterForSelectedChecklistItems() {
      return this.activeChecklistItems.filter((i) => i.selected)
    },
    generateId() {
      return uuidv4()
    },
    _addNewChecklistItem() {
      let itemObj = {
        id: this.generateId(),
        selected: false,
        text: this.tempItemText,
      }
      mutations.addNewChecklistItem(state, itemObj)

      /** Reset the relevant data points. */
      this.prompt = false
      this.tempItemText = ''

      /** Update checklist page dimensions */
      this.updatePageDimensions()
    },
    _removeSelectedChecklistItems() {
      mutations.removeSelectedChecklistItems(state, this.filterForSelectedChecklistItems())
    },
    openUpdateChecklistItemPrompt(checklistItemObj) {
      this.updateItemPrompt = true
      this.updateChecklistItemObj = checklistItemObj
      this.tempItemText = checklistItemObj.text
    },
    _updateChecklistItem() {
      this.updateChecklistItemObj.text = this.tempItemText
      mutations.updateChecklistItem(state, this.updateChecklistItemObj)
      this.updateChecklistItemObj = {}
      this.tempItemText = ''
      this.updateItemPrompt = false
    },
    closePrompt() {
      this.tempItemText = ''
      /**
       * The prompt is toggled to "false" by the "v-close-popup" attribute
       * on the popup's "Cancel" button.
       */
    },
  },
}
</script>
