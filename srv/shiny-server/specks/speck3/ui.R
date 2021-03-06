# Define UI for application that draws a histogram.

# A quick fix to Shiny/ R cache issue.
# Fetch all site names.
sites <- dbGetQuery(
    DB,
    "SELECT
        nid,
        title,
        code
    FROM nodes
    WHERE datatype = 'speck'
    AND nid != '346'
    AND visible = '1'
    AND code NOT NULL"
)

# Set the nid and title.
site_choices <- setNames(sites$nid, paste(sites$code, ' - ', sites$nid))

# Set choices of title and code for select input.
species_choices <- c(
    'PM 2.5 particulates ug/m3' = 'PM2.5'
)

# Set choices of title and code for select input.
means_choices <- c(
    '1 min' = '1 min',
    '1 hour' = '1 hour',
    '24 hour' = '24 hour'
)

# Set choices of title and code for select input.
conditions_choices <- c(
    'Device Humidity %' = 'humidity',
    'Temperature in Fahrenheit' = 'tempi',
    'Humidity %' = 'hum',
    'Wind speed in miles per hour' = 'wspdi',
    'Wind direction in degrees' = 'wdird'
)

# Site 1 options.
site1 <- selectInput(
    inputId = "site1",
    label = "Select a first site:",
    choices = site_choices
)

# Site 2 options.
site2 <- selectInput(
    inputId = "site2",
    label = "Select a second site:",
    choices = c('None', site_choices)
)

# Add name attributes.
# Make multiple level array.
site1$children[[2]]$children[[1]]$attribs$name <- "sites[site1]"
site2$children[[2]]$children[[1]]$attribs$name <- "sites[site2]"

# UI
shinyUI(fluidPage(verticalLayout(

    # Change the font size.
    # !Important:
    # When the page initially loads there is not a vertical scrollbar on the page, and when the data is rendered then a vertical scrollbar appears, changing the size of the container that the plot sits in, which causes it to re-render.
    # If so, you can use this CSS to make the problem go away: body { overflow-y: hidden; } or body { overflow-y: scroll; }
    # Ref: https://groups.google.com/forum/#!topic/shiny-discuss/PhixkFqHi3c
    tags$style(
        type='text/css',
        "body { overflow-y: scroll; overflow-x: hidden;}

        .datepicker,
        .control-label,
        .radio,
        .selectize-input,
        .selectize-dropdown,
        .action-button,
        .button-download,
        .shiny-download-link { font-size: 11px; }

        .selectize-dropdown { padding:2px ; }

        .container-fluid,
        .col-sm-4:nth-of-type(1) { padding-left: 0 !important; padding-right: 0 !important; }

        #link {visibility: hidden;}
        "
    ),

    wellPanel(

        fluidRow(
            column(3,
                # Function options.
                radioButtons(
                    inputId = "plot",
                    label = "Select a graph or a plot:",
                    choices = c(
                        "Line Graph" = "line",
                        "Scatter Plot" = "scatter",
                        "Polar Plot" = "polar1",
                        "Polar Plot PM2.5 > 15 ug/m3" = "polar2",
                        "Rose Plot" = "rose",
                        "Calendar Plot" = "calendar",
                        "Time Plot" = "time"
                    ),
                    selected = NULL,
                    inline = FALSE
                ),

                # Condition for line graph.
                conditionalPanel(
                    condition = "input.plot == 'line' && input.site1 != 'None' && input.site2 != 'None'",
                    radioButtons(
                        inputId = "variation_line",
                        label = "Choose a variation:",
                        choices = c(
                            "Multiple" = "multiple",
                            "Single" = "single"
                        ),
                        selected = NULL,
                        inline = FALSE
                    )
                )
            ),
            column(5,

                # Site select input.
                # Condition when the plot is a line plot.
                conditionalPanel(
                    condition = "input.plot != 'googlemaps'",
                    site1
                ),

                # Condition when the plot is a line plot.
                conditionalPanel(
                    condition = "input.plot == 'line'",
                    site2
                ),

                # Species/ pollutant options
                selectInput(
                    inputId = "species",
                    label = "Species:",
                    choices = species_choices
                ),

                # Condition for line graph.
                conditionalPanel(
                    condition = "input.plot == 'line' && input.variation_line != 'single'",
                    radioButtons(
                        inputId = "condition",
                        label = "Choose a Weather Condition:",
                        choices = c(
                            "Weather Conditions" = "yes",
                            "No Weather Condition" = "none"
                        ),
                        selected = NULL,
                        inline = FALSE
                    )
                ),

                # Condition when the plot is not Polar Plot.
                conditionalPanel(
                    condition = "input.condition == 'yes' && input.variation_line != 'single' && input.plot != 'polar1' && input.plot != 'polar2' && input.plot != 'rose' && input.plot != 'calendar' && input.lineVariation != 'single' && input.plot != 'time'",
                    selectInput(
                        inputId = "conditions",
                        label = "Weather Conditions:",
                        choices = conditions_choices
                    )
                )

            ),
            column(4,

                # Date.
                conditionalPanel(
                    condition = "input.plot != 'calendar'",
                    # Date from.
                    dateInput(
                        inputId =  "date_from",
                        label = "Select time period:",
                        value = "2014-10-09",
                        format = "MM d, yyyy"
                    ),

                    # Date to.
                    dateInput(
                        inputId =  "date_to",
                        label = "To:",
                        #value = Sys.Date(),
                        value = "2015-06-24",
                        format = "MM d, yyyy"
                    )
                ),

                # Year.
                conditionalPanel(
                    condition = "input.plot == 'calendar'",
                    #numericInput("year", "Year:", 2014,
                    #min = 2014, max = 2015)
                    selectInput(
                        inputId = "year",
                        label = "Year:",
                        choices = c(2014, 2015)
                    )
                ),

                # Mean.
                # Condition when the plot is a line plot or a scatter plot.
                conditionalPanel(
                    condition = "input.plot == 'line'",
                    selectInput(
                        inputId = "mean",
                        label = "Mean:",
                        choices = means_choices
                    )
                ),

                actionButton('goPlot', 'Enter'),
                downloadButton('downloadPlot', 'Download plot'),
                downloadButton('downloadData', 'Download csv')
            )
        )
    ),
    # wellPanel

    div(

        #textOutput("test")

        # Plot the data.
        plotOutput("plot")
    )
    # div

)))
