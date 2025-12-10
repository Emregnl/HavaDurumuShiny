
library(shiny)
library(bslib)
library(httr)
library(jsonlite)

options(sass.cache = FALSE)

##### ARAYUZ (UI) 
ui <- fluidPage(
  theme = bs_theme(bootswatch = "cyborg"), 
  
  div(style = "text-align: center; padding: 20px;",
      h1("Hava Durumu Istasyonu"),
      p("Emre'nin Uygulamasi", style = "color: gray;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("sehir","Sehir Seciniz:",
                  choices = c("Istanbul", "Ankara", "Izmir", "Bursa", 
                              "Antalya", "Adana", "Konya", "Gaziantep", 
                              "Trabzon", "Samsun", "Eskisehir", "Kayseri",
                              "Diyarbakir", "Mersin", "Canakkale")),
      actionButton("getir", "Hava Durumunu Goster", class = "btn-info", style = "width: 100%;"),
      hr(),
      helpText("Veriler OpenWeatherMap sitesinden alinmaktadir.")
    ),
    mainPanel(uiOutput("sonuc_kutusu"))
    )
)
 server <- function(input,output,session) {
   observeEvent(input$getir,{
     # API SIFREN:
     api_key <- "BURAYA_KENDI_API_KEYINIZI_YAZIN"
     
     url <- paste0("http://api.openweathermap.org/data/2.5/weather?q=",
                   input$sehir, "&appid=", api_key, "&units=metric&lang=tr")
     tryCatch({
       gelen <- GET(url)
       
       if (status_code(gelen) != 200) {
         output$sonuc_kutusu <- renderUI({ 
           div(class = "alert alert-danger",
               h3("Anahtar Henuz Aktif Degil"),
               p("Lutfen 10-15 dakika bekleyip tekrar dene.")
               
            )
         })
       } else {
      
icerik <- fromJSON(content(gelen, "text", encoding = "UTF-8"))
derece <- round(icerik$main$temp, 1)
ikon <- paste0("http://openweathermap.org/img/wn/", icerik$weather$icon[[1]], "@4x.png")
desc <- icerik$weather$description

output$sonuc_kutusu <- renderUI({
  div(style = "background-color: #222; padding: 20px; border-radius: 15px; text-align: center;",
      h2(icerik$name, style="color: #17a2b8;"),
      img(src = ikon, width = "150px"),
      h1(paste0(derece, " C"), style = "font-size: 60px; font-weight: bold;"),
      h4(desc, style = "color: #bbb;"),
      hr(),
      p(paste("Nem: %", icerik$main$humidity)),
      p(paste("Ruzgar:", icerik$wind$speed, "km/s"))
  )
})
       }
     }, error = function(e) { print(e) })
   })
 }
 
 shinyApp(ui, server)
 