# Dashboard Professional Redesign - CSS Quick Reference

## Color Palette

```css
/* Primary Colors */
--primary-blue: #003f87;        /* Main banking blue */
--accent-blue: #0066cc;         /* Secondary actions */
--secondary-blue: #001a4d;      /* Dark backgrounds */
--light-blue: #f0f4f8;          /* Light backgrounds */

/* Status Colors */
--success-green: #00a86b;       /* Success/positive actions */
--warning-orange: #ff6b35;      /* Alerts/warnings */
--danger-red: #ef4444;          /* Errors/failures */

/* Text Colors */
--text-dark: #1f2937;           /* Primary text */
--text-light: #6b7280;          /* Secondary text */
--text-lighter: #9ca3af;        /* Tertiary text */

/* Utility Colors */
--border-gray: #e5e7eb;         /* Borders */
--background-gray: #f9fafb;     /* Card backgrounds */
--light-gray: #f8f9fa;          /* Light backgrounds */
--white: #ffffff;               /* Pure white */
```

## Component Styling Guide

### Account Balance Card
```css
/* Gradient background */
background: linear-gradient(135deg, #001a4d 0%, #003f87 50%, #0066cc 100%);

/* Text styling */
color: white !important;
font-size: 48px;
font-weight: 700;

/* Container */
padding: 48px;
border-radius: 16px;
box-shadow: 0 12px 48px rgba(0, 26, 77, 0.25);
```

### Action Buttons
```css
/* Grid Layout */
display: grid;
grid-template-columns: 1fr 1fr 1fr;
gap: 16px;

/* Button Styling */
padding: 18px;
border-radius: 12px;
color: white;
font-weight: 600;

/* Transfer Button */
background: linear-gradient(135deg, #003f87 0%, #0066cc 100%);

/* Request Button */
background: linear-gradient(135deg, #00a86b 0%, #00c073 100%);

/* Services Button */
background: linear-gradient(135deg, #ff6b35 0%, #ff8c42 100%);
```

### Widget Styling
```css
/* Standard Widget */
background: white;
padding: 20px;
border-radius: 14px;
box-shadow: 0 2px 12px rgba(0,0,0,0.06);
margin-bottom: 20px;
```

### Quick Links
```css
.quick-link-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 12px;
    border-radius: 8px;
    color: #1f2937;
    transition: all 0.3s ease;
    font-size: 13px;
    font-weight: 500;
}

.quick-link-item:hover {
    background-color: #f0f4f8;
    transform: translateX(4px);
}

.quick-link-item:hover i {
    transform: scale(1.15);
}
```

### Table Header
```css
.table thead th {
    background-color: #f9fafb;
    border-bottom: 2px solid #e5e7eb;
    color: #6b7280;
    font-weight: 600;
    padding: 12px 16px;
    text-transform: uppercase;
    font-size: 12px;
    letter-spacing: 0.5px;
}
```

### Table Row Hover
```css
.table tbody tr {
    border-bottom: 1px solid #f3f4f6;
    transition: all 0.3s ease;
    cursor: pointer;
}

.table tbody tr:hover {
    background-color: #f9fafb;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}
```

### Status Badges
```css
.text-success {
    color: #00a86b;
    font-weight: 600;
}

.text-success::before {
    content: '';
    display: inline-block;
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background-color: #00a86b;
    margin-right: 6px;
}

.inprogress {
    color: #ff6b35;
    font-weight: 600;
}

.inprogress::before {
    background-color: #ff6b35;
}

.danger {
    color: #ef4444;
    font-weight: 600;
}

.danger::before {
    background-color: #ef4444;
}
```

### Security Widget
```css
/* Progress Bar */
background: linear-gradient(90deg, #003f87 75%, #e5e7eb 75%);
height: 6px;
border-radius: 3px;

/* Alert Box */
background: #fff3cd;
border-left: 3px solid #ff6b35;
padding: 12px;
border-radius: 8px;
```

### Notifications
```css
.notification-item {
    padding: 12px;
    border-radius: 8px;
    background: #f9fafb;
    margin-bottom: 8px;
    border-left: 3px solid #003f87;
    font-size: 13px;
}
```

## Typography

```css
/* Headings */
h6 {
    color: #1f2937;
    font-weight: 700;
    font-size: 14px;
}

h5 {
    color: #1f2937;
    font-size: 20px;
    font-weight: 700;
}

/* Body Text */
p {
    color: #1f2937;
    font-size: 13-14px;
}

/* Secondary Text */
.mdr {
    color: #6b7280;
    font-size: 12px;
    font-weight: 400;
}

/* Font Stack */
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
```

## Spacing Standards

```css
/* Container Padding */
.dashboard-section: 40px 0
Widgets: padding: 20px
Items: padding: 10px 12px

/* Gaps */
Grid Gap: 16px
Flex Gap: 12px
Item Gap: 8px

/* Margins */
Bottom Spacing: margin-bottom: 20px (widgets)
Bottom Spacing: margin-bottom: 8px (items)
```

## Shadow Standards

```css
/* Subtle Shadow (Default) */
box-shadow: 0 2px 12px rgba(0,0,0,0.06);

/* Hover Shadow */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

/* Prominent Shadow */
box-shadow: 0 12px 48px rgba(0, 26, 77, 0.25);

/* Accent Shadow */
box-shadow: 0 4px 16px rgba(0,0,0,0.08);
```

## Border Radius Standards

```css
/* Widgets and Cards */
border-radius: 14px;

/* Items and Buttons */
border-radius: 12px;

/* Input Fields and Links */
border-radius: 8px;

/* Progress Bars */
border-radius: 3px;
```

## Animation/Transition Standards

```css
/* Standard Transition */
transition: all 0.3s ease;

/* Smooth Easing */
cubic-bezier(0.4, 0, 0.2, 1)

/* Icon Scaling */
transform: scale(1.15);

/* Slide Animation */
transform: translateX(4px);

/* Hover Elevation */
transform: translateY(-2px);
```

## Responsive Design Breakpoints

```css
/* Desktop (1200px+) */
grid-template-columns: 1fr 1fr 1fr;

/* Tablet (768px - 1199px) */
/* Consider 2 columns for some layouts */

/* Mobile (< 768px) */
/* Consider single column for optimal readability */
```

## Icon Styling

```css
/* Standard Icon */
width: 20px;
display: inline-block;
color: #003f87; /* or appropriate status color */

/* Icon Transitions */
transition: transform 0.3s ease;

/* Icon Hover */
transform: scale(1.15);
```

---

## Implementation Notes

1. **Color System**: Use CSS variables from dashboard-enhancements.css for consistency
2. **Shadows**: Apply subtle shadows for depth without overwhelming
3. **Spacing**: Maintain consistent padding/margins throughout
4. **Transitions**: Use 0.3s ease for all interactive elements
5. **Typography**: Use system font stack for optimal performance
6. **Accessibility**: Maintain WCAG AA contrast ratios for all text
7. **Hover States**: Provide visual feedback on all interactive elements

