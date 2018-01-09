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
import { SharedModule } from "./shared/shared.module";
import { AppStore } from './app.store';
import { FormComponent } from './form/form.component';
import { ItemCardListSetComponent } from './item-card-list-set/item-card-list-set.component';
import { FormsModule } from '@angular/forms';

@NgModule({
  declarations: [
    AppComponent,
    ItemCardComponent,
    ItemCardListComponent,
    FormComponent,
    ItemCardListSetComponent
  ],
  imports: [
    BrowserModule,
    MaterialModule,
    HttpClientModule,
    FormsModule,
    // .forRoot() is only used in root module(app.module.ts)
    SharedModule.forRoot()
  ],
  providers: [
    MediumService,
    HatenaService,
    SlideShareService,
    AppStore
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
