import { NgModule } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule, MatButton } from '@angular/material/button';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MatInputModule } from '@angular/material/input';
import {MatIconModule} from '@angular/material/icon';
@NgModule({
  imports: [
    NoopAnimationsModule,
    MatButtonModule,
    MatCardModule,
    MatInputModule,
    MatIconModule
  ],
  exports: [
    NoopAnimationsModule,
    MatButtonModule,
    MatCardModule,
    MatInputModule,
    MatIconModule
  ]
})
export class MaterialModule { }
