# Styling the Savings United Voucher App

## Working with SASS

This SASS project was created with following considerations:

1. **Linter**: Activate your stylelinter, the config file is placed in the base directory!
1. **Colors**: Only use color variables from `/base/colors.scss`, avoid direct hex codes.
1. **!important**: Never use !important rule in css unless there's no way around.
1. **Ranges**: The range of margins, paddings or similar are set by 4px. E.g. a margin
should be sth. like 4px, 8px, 12px, 20px, etc.. This assures that we use the same ranges
across the whole project.
1. **Units**: Don't use px unity, use rem or em. Default size is 16px.
Use this REM converter: <https://offroadcode.com/rem-calculator/>
1. **Mobile first**:
    * Start with mobile styles first,
    * create only "up"-breakpoints for tablet and desktop,
    * place breakpoint only at the bottom of the file,
    * don't use "down"-breakpoints,
    * use each breakpoint just once per file,
    * place breakpoints on top-level or max. just one indent!

## Rebatly color settings

To use the "Mobile 2017" theme for Rebatly, following colors have to be set in the backend >
Settings > Style Settings. Make sure "Custom styles enabled" is checked.

1. Brand Colors
    * Primary color: `#3f51b5`
    * Secondary color: `#ff4081`
    * Tertiary color: `#37bb9d`
    * Quaternary color: `#37bb9d`
1. Header Colors
    * Background color: `#3f51b5`
    * Font color: `#fafaff`
1. Main Colors
    * Background color: `#f6f6f6`
    * Box border color: `#999db1`
    * Primary font color: `#3f51b5`
    * Secondary font color: *leave blank*
    * Tertiary font color: *leave blank*
    * Text link color: `#2e5dec`
1. Footer Colors
    * Background color: `#2e303e`
    * Primary font color: `#fafaff`
    * Secondary font color: `#727582`
1. Font Family
    * Base font: `Open Sans (default)`
    * Heading h1: `Museo Sans`
    * Heading h2: `Museo Sans`
    * Heading h3: `Museo Sans`
    * Heading h4: `Museo Sans`

