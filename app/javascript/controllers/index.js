// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Register new controllers
import DialogController from "./dialog_controller"
import ToastController from "./toast_controller"

application.register("dialog", DialogController)
application.register("toast", ToastController)
