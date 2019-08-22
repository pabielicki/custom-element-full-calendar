customElements.define('full-calendar', class extends HTMLElement {
    constructor() {
        super();
        this._calendarEvents = [];
        this._locale = 'pl';
        this._timeZone = 'local';

    }

    get calendarEvents() {
        return this._calendarEvents;
    }

    set calendarEvents(value) {
        if (this._calendarEvents === value) return;
        this._calendarEvents = value;
    }

    connectedCallback(){
        this._calendar = new FullCalendar.Calendar(this, {
            dateClick: function(info) {
                var time = info.date.getTime();
                // console.log(this);
                window.dispatchEvent(new CustomEvent('dateSelected', {time: time}));
            },
            plugins: [ 'dayGrid', 'timeGrid', 'interaction'],
            header: {
                left: 'dayGridMonth,timeGridWeek,timeGridDay',
                center: 'title',
            },
            events: this._calendarEvents,
            locale: this._locale,
            timeZone: this._timeZone,
        });
        this._calendar.render();
    }
});
