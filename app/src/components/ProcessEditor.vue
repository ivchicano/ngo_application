  <template>
  <div class="container" >
    <q-card>
    <q-card-section :hidden="hideForm">
         <q-tabs
          v-model="langTab"
          dense
          class="text-grey"
          active-color="primary"
          indicator-color="primary"
          align="justify"
          narrow-indicator
        >
          <q-tab
            v-for="language in languages"
            :key="language.lang"
            :name="language.name"
            :label="language.name"
          />
        </q-tabs>
        <q-tab-panels
          v-model="langTab"
          animated
        >
          <q-tab-panel
            v-for="language in languages"
            :key="language.lang"
            :name="language.name"
          >
        <q-input
          v-model="int_comment_shell.translations.filter(filterTranslationModel(language.lang))[0].comment"
          filled
          type="textarea"
          label="Comment"
        />
        </q-tab-panel>
        </q-tab-panels>
        <q-btn color="accent" unelevated rounded style="width:70px;border-radius:2px" label="Save" @click="saveComment(int_comment_shell)" />
        <q-btn class="button" unelevated rounded style="width:70px;border-radius:2px" label="Cancel" @click="cancelComment()" />
        <q-btn class="button" unelevated rounded style="width:70px;border-radius:2px" label="Delete" @click="deleteComment(int_comment_shell)" />
    </q-card-section>
    </q-card>
  <div style="text-align:center;padding-top:10px">
   <div class="col" style="display:inline-block;padding-right:20px;padding-left:20px">
   <q-input style="border-radius:10px; width:590px;font-size:18px" dense items-center filled v-model="search" label="Search" >
   <template v-slot:append>
          <q-avatar>
            <img src="https://cdn.quasar.dev/logo/svg/quasar-logo.svg">
          </q-avatar>
        </template>
    </q-input>
  </div>
  <div class="col" style="display:inline-block;text-align:right;width:135px">
   <q-btn style="width:135px; margin-bottom:15px" color="accent" rounded label="Add Process" no-caps size="15px" to="guided_process_editor/edit" />
  </div>
  </div>
  
  <div style="text-align:center;">
    <q-list style="display:inline-block;width:750px" >
        <Process v-for="process in filteredProcesses"
         ref="process"
         :process="process"
         :key="process.id"
         :Title="showProcessLabel(process)"
         :Tag_1="process.user_tags"
         :Tag_2="process.topic_tags"
         :Link="process.id"
         Path="guided_process_editor"
         @remove="deleteProcess"
         @comment="editComment">
        </Process>
    </q-list>
    </div>
  </div>
</template>


<script>
import Process from './guided_process_editor/Process'
import editEntityMixin from '../mixin/editEntityMixin'
export default {
  name: 'DocumentType',
  props: {
    msg: String
  },
    mixins: [editEntityMixin],
  components: {
   Process
  },
  data () {
    return {
      is_new : true,
      search: ' ',
      hideForm: true,
      int_comment_shell : {id:-1, idProcess: -1, translations:[]}
    }
  },
  computed: {
     processes () {
      return this.$store.state.flows.flows
    }, 
    filteredProcesses () {
        //if none of the fields is filled in it will give the full list of processes
        if( this.search == "") {
          return this.processes
        }
        else {
          /* THIS IS THE LOGIC FOR THE LINK TO THE BACKEND */
          return this.processes.filter((a_process) => {
            console.log(this.activeLanguage)
          var curlangproc = a_process.translations.filter((transl) => { return transl.lang == this.activeLanguage })[0]
          console.log("this is curlangproc")
          console.log(curlangproc)
          //Splits the search field and puts the words in an array
          var searchArray = this.search.split(" ")
          if (searchArray.every(string => curlangproc.process.toLowerCase().includes(string))) {
            return true;
          }        })

       /*    return this.processes.filter((filt) =>{
          //Splits the search field and puts the words in an array
          var searchArray = this.search.split(" ")
          if( searchArray.every(string => filt.title.toLowerCase().includes(string))){
              return true;
            }}) 
        } */
        }
    }, 
    comments(){
      return this.$store.state.comments.comments
    }
  },
  methods: {
    showProcessLabel (workingProcess) {
      return workingProcess.translations.filter(this.filterTranslationModel(this.activeLanguage))[0].process
    },
     deleteProcess(value) {
      var deletedProcess = this.processes.filter((filt) => {
          console.log("in fil")
          console.log(filt)
          return filt.id == value
        })  
      this.$store.commit('flows/deleteProcess', deletedProcess[0])
    },
    saveComment(int_comment_shell){
      var the_process = this.processes.filter ((a_process) => {
      return a_process.id == int_comment_shell.idProcess
    })[0]
    console.log("i am the process")
    console.log(the_process)
    if(this.is_new){
    
    this.$store.dispatch('comments/saveComments', {comment : this.int_comment_shell, process: the_process})
    
    // console.log(new_comment)
    this.hideForm = true
    this.createShell()
    for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].restore()
      }
     
     
    }
    else{
      this.$store.dispatch('comments/editComments',  {comment : this.int_comment_shell, process: the_process})
      console.log("EDITED")
      console.log(this.$store.comments)
      this.hideForm = true
      for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].restore()
      }
      this.createShell()
    }
    },
    cancelComment(){
      this.createShell()
      this.hideForm = true
      for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].restore()
      }
    },
     deleteComment(comment){
      this.$store.dispatch('comments/deleteComments', comment.id)
      this.hideForm = true
      for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].restore()
      }
    },
    editComment(value){
       /*THIS IS THE VERSION OF EDIT THAT WORKS WITH THE BACKEND*/
       console.log("THIS IS THE PROCESS")
      console.log(value)
      var process_comments = []
      var current_comment = null
      if(value.comments != null){
      value.comments.forEach((comment) =>{
        process_comments.push(comment.idcomment)
      })
      }
      for(var i = 0; i<process_comments.length; i++){
        var the_comment = this.comments.filter((com) => {
        //console.log(com.id)
        //console.log(process_comments[i])
       return com.id == process_comments[i]
     })[0]
     
     if( the_comment != null ){
       current_comment = the_comment
       break;
       
     }
     }
    console.log(current_comment)
     console.log("I AM THE CIMMMENT")
     console.log(current_comment)
     if(current_comment == null){
       console.log("inside if")
       this.is_new = true
       this.createShell()
       this.int_comment_shell.idProcess = value.id
        for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].hide()
      }
       this.hideForm= false
    

     }
     else{
              console.log("inside else")

    this.is_new = false
     this.mergeProcess(current_comment)
     console.log(current_comment)
      console.log(value)
      for(var i = 0; i< this.$refs.process.length; i++){
        this.$refs.process[i].hide()
      }
      console.log(this.$refs.process)
      //this.$refs.process.restore()
       this.hideForm = false
     }
    
    },
createShell () {
      this.int_comment_shell = { id: -1, idProcess : -1, translations:[], published: false, publicationdate: null }
      this.languages.forEach(l => {
        this.int_comment_shell.translations.push({ id: -1, lang: l.lang, comment: '', translationDate: null })
      });
    },
    mergeProcess (comment) {
      console.log("MERGING")
      console.log(process)
      this.int_comment_shell.id = comment.id
      this.int_comment_shell.idProcess = comment.idProcess
      
      //this.edit_process.applicableUsers = process.applicableUsers
      //    this.edit_process.processTopics = process.processTopics
      comment.translations.forEach(pr => {
        console.log(pr)
        //    this.int_topic_shell.translations.filter(function(sh){return sh.lang == tr.lang})
        for (var i = 0; i < this.int_comment_shell.translations.length; i++) {
          if (this.int_comment_shell.translations[i].lang == pr.lang) {
            this.int_comment_shell.translations.splice(i, 1);
            this.int_comment_shell.translations.push(JSON.parse(JSON.stringify(pr)))
            break;
          }
        }
      });
      
      }
  },
  created () {
    this.createShell()
    this.loading = true
    console.log(this.$store);
    this.$store.dispatch('flows/fetchFlows')
      .then(processes => {
        this.loading = false
        console.log(processes)
      })  
      this.$store.dispatch('comments/fetchComments')
      .then(comments => {
        this.loading = false
      })  
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container {
  padding-top: 50px;
  padding-right: 80px;
  padding-bottom: 50px;
  padding-left: 80px;
}
</style>
© 2020 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
