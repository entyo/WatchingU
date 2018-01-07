import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { AppComponent } from './app.component';

import { MaterialModule } from './material/material.module';
import { MediumService } from './medium.service';
import { HatenaService } from './hatena.service';
import { SlideShareService } from './slideshare.service';
import { ItemCardComponent } from './item-card/item-card.component';
import { ItemCardListComponent } from './item-card-list/item-card-list.component';

@NgModule({
  declarations: [
    AppComponent,
    ItemCardComponent,
    ItemCardListComponent
  ],
  imports: [
    BrowserModule,
    MaterialModule,
    HttpClientModule
  ],
  providers: [
    MediumService,
    HatenaService,
    SlideShareService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
